# AutoLeitura

App Flutter (`autoleitura`) Android-only, com a API PHP em `api/` (antes um repo separado, agora parte deste repo).

## Layout & gotchas

- `lib/` é plano; entrypoint `lib/main.dart`. Fluxo realmente ligado no código: AutoLeituraScreen (splash) → Home → Login → Leitura. A cadeia `Conta → ExibirDetalhes → ExibirConta → GerarPDFScreen` existe em `lib/conta.dart`/`exibirdetalhes.dart`/`exibirconta.dart`/`gerarpdf.dart`, mas **`Conta` é código morto** — nada a instancia (o fluxo de sucesso de `Leitura` só mostra um dialog, não navega).
- Estado via `scoped_model` (`LoginModel`/`UserModel` em `lib/login.dart`).
- `api/` contém a API PHP. `api/conexao/env_prod.php` (credenciais MySQL) e `api/logs/logs.log` (dados reais de usuários) são gitignored — o checkout não os tem. Para rodar a API localmente, crie `api/conexao/env.php` a partir de `env_prod.php` (presente apenas localmente).
- **Não há `.env`.** A URL da API é hardcoded em `lib/login.dart:9` (`/usuario`) e `lib/leitura.dart:5` (`/postLeituras`) como `https://api.autoleitura.online`. Para trocar o endpoint, edite essas constantes.
- `Conta`/`ExibirDetalhes`/`ExibirConta`/`GerarPDFScreen` usam dados placeholder: usuário fake "João Carlos", R$1.15/m³, `leituraAnterior=0`.
- Plataformas: somente `android/`. Não recriar `web/`/`linux/` (deploy web Vercel foi descontinuado).
- `.scripts/` e `.deploy_homol/` são mantidos em git para o job Deploy do CI (mail + download do APK). `downloadAPK.sh` é stub com placeholders `OWNER/REPO/ARTIFACT_ID`.
- `test/widget_test.dart` está desatualizado: asserta textos (ex.: "Seja Bem-Vindo ao sistema de Auto Leitura", "Confira seu código", "Validar") que não existem em `lib/`, então `flutter test` falha. Mudanças de UI devem atualizar/ignorar esse teste.

## Comandos

- `flutter pub get` (regenera `pubspec.lock` — Flutter não está instalado nesta máquina)
- `flutter analyze` (lints: flutter_lints + `library_private_types_in_public_api`)
- `dart format lib test`
- `flutter test` / `flutter test --coverage`
- `flutter build apk` (CI gera `build/app/outputs/apk/release/app-release.apk`)

## API (PHP, em `api/`)

- Sem framework: router próprio `index.php` → `Router.php` → `RouteSwitch.php` → `endpoints/**`. O `.htaccess` de `api/` faz rewrite de toda rota para `index.php`; no Router, o nome da rota vira método no RouteSwitch (`/usuario` → `usuario()`, `/postLeituras` → `postLeituras()`).
- Respostas: `{"code":0|1,"message":...}` ou `{"code":1,"result":[...]}`.
- MySQL via PDO; `conexao/conn.php` inclui `env.php`, que **não existe** no checkout — copie `conexao/env_prod.php` → `conexao/env.php` para rodar localmente.
- CORS está **desativado** (comentado) em `configs/config.php` — o app é Android-only; a URL do Vercel antiga só permanece como comentário.
- O app espera `GET /usuario?id=N` → `{code:1,result:[{id,local,nome,celular,email}]}` e `POST /postLeituras` (JSON `{codigo,leitura}`) → `{code:0}`.
- Schema do banco: `sql/db_autoleitura.sql`.

## Git / CI

- **Commit-msg hook obrigatório**: todo commit precisa de Emoji + Conventional Commit (`<emoji> <tipo>(<escopo>): <descrição>`, tipos: feat/fix/docs/style/refactor/test/chore/build/ci/perf/revert/raw/cleanup/remove). O hook fica em `.githooks/commit-msg` e é ativado via `git config core.hooksPath .githooks` (config local, não versionada).
- Trabalhar em `develop`/`feature-api` (branch atual do checkout; `feature-api` é idêntica a `develop`). `master` só recebe merge/PR e é **protegida** (exige 1 review, bloqueia push/force direto).
- CI (`.github/workflows/develop.yaml`) dispara em push para `master` (merge da develop), `pull_request` para `master` e `workflow_dispatch`. Não dispara em push para `develop`/`feature-api`. O job Deploy roda apenas em push (merge), não em PR.
- Pipeline: Build (`flutter build apk`, Flutter 3.13.8) → upload de artefato → Deploy (download do APK + email). O job de teste está comentado e **não** roda no CI.
- `.scripts/*.sh` são helpers do CI (Telegram/email).