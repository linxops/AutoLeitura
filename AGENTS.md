# AutoLeitura

App Flutter (`autoleitura`) Android-only, com a API PHP em `api/` (antes um repo separado, agora parte deste repo).

## Layout & gotchas

- `lib/` é plano; entrypoint `lib/main.dart`. Fluxo realmente ligado no código: AutoLeituraScreen (splash) → Home → Login → Leitura. A cadeia `Conta → ExibirDetalhes → ExibirConta → GerarPDFScreen` existe em `lib/conta.dart`/`exibirdetalhes.dart`/`exibirconta.dart`/`gerarpdf.dart`, mas **`Conta` é código morto** — nada a instancia (o fluxo de sucesso de `Leitura` só mostra um dialog, não navega).
- Estado via `scoped_model` (`LoginModel`/`UserModel` em `lib/login.dart`).
- `api/` contém a API PHP. `api/conexao/env_prod.php` (credenciais MySQL) e `api/logs/logs.log` (dados reais de usuários) são gitignored — o checkout não os tem. Para rodar a API localmente, crie `api/conexao/env.php` a partir de `env_prod.php` (presente apenas localmente).
- **Não há `.env`.** A URL da API vem de `const apiBaseUrl = String.fromEnvironment('API_URL', defaultValue: 'https://api.autoleitura.online')` em `lib/login.dart`/`lib/leitura.dart`. O CI (Android) usa o default; o docker-compose local injeta `--dart-define=API_URL=http://localhost:8000` no build web.
- `Conta`/`ExibirDetalhes`/`ExibirConta`/`GerarPDFScreen` usam dados placeholder: usuário fake "João Carlos", R$1.15/m³, `leituraAnterior=0`. **Atenção (web)**: `gerarpdf.dart` importa `dart:io`/`open_file` e só não quebra o build web porque a cadeia `Conta` é código morto (não importada do `main`). Se religar essa cadeia, trate `dart:io` para compilar em web.
- Plataformas: `android/` (deploy real). `web/` existe **apenas para teste local** via docker-compose (`flutter build web` roda no container `web`; o build é servido por nginx). Não recriar `linux/` (deploy web Vercel foi descontinuado). Toolchain migrada para o template do Flutter 3.47 (Kotlin DSL: AGP 9.1.0, Gradle 9.3.1, Kotlin 2.4.0, Java 17 — o CI instala JDK 17 via setup-java@v4).
- Infra local (`docker-compose.yml`): 3 serviços interligados — `db` (MariaDB 11.4, carrega `api/sql/db_autoleitura.sql`), `api` (PHP 8.4 Apache, gera `conexao/env.php` das envs `MYSQL_*`; CORS só se `ALLOW_CORS_ORIGIN` existir — configurado em `conexao/conn.php`) e `web` (Flutter web → nginx). Portas: DB `3306`, API `8000`, Web `8081`. Use `docker compose up --build` (primeira vez baixa a imagem do Flutter ~4GB). O CORS do teste local libera `http://localhost:8081`; em produção/Android fica desativado.
- `.scripts/` e `.deploy_homol/` são mantidos em git para o job Deploy do CI (mail + download do APK). `downloadAPK.sh` é stub com placeholders `OWNER/REPO/ARTIFACT_ID`.
- `test/widget_test.dart` está desatualizado: asserta textos (ex.: "Seja Bem-Vindo ao sistema de Auto Leitura", "Confira seu código", "Validar") que não existem em `lib/`, então `flutter test` falha. Mudanças de UI devem atualizar/ignorar esse teste.

## Comandos

- `flutter pub get` (regenera `pubspec.lock` — Flutter não está instalado nesta máquina)
- `flutter analyze` (lints: flutter_lints + `library_private_types_in_public_api`)
- `dart format lib test`
- `flutter test` / `flutter test --coverage`
- `flutter build apk` (CI gera `build/app/outputs/apk/release/app-release.apk`)
- `docker compose up --build` (infra local: db + api + web — ver "Layout & gotchas")

## API (PHP, em `api/`)

- Sem framework: router próprio `index.php` → `Router.php` → `RouteSwitch.php` → `endpoints/**`. O `.htaccess` de `api/` faz rewrite de toda rota para `index.php`; no Router, o nome da rota vira método no RouteSwitch (`/usuario` → `usuario()`, `/postLeituras` → `postLeituras()`).
- Respostas: `{"code":0|1,"message":...}` ou `{"code":1,"result":[...]}`.
- MySQL via PDO; `conexao/conn.php` inclui `env.php`, que **não existe** no checkout — copie `conexao/env_prod.php` → `conexao/env.php` para rodar localmente. No docker-compose, o container `api` gera esse `env.php` automaticamente a partir das envs `MYSQL_*`.
- CORS está **desativado** por padrão (o app é Android-only; a URL do Vercel antiga só permanece como comentário em `configs/config.php`). Para teste local do Flutter web, o CORS é ativado apenas quando a env `ALLOW_CORS_ORIGIN` existe (lógica em `conexao/conn.php`; o compose define `http://localhost:8081`).
- O app faz `POST /login` (JSON `{codigo,senha}`) → `{code:1,result:[{id,local,nome,celular,email,role}]}` (senha bcrypt; `role` = `usuario`/`admin`) e `POST /postLeituras` (JSON `{codigo,leitura}`) → `{code:0}`. A doc completa dos endpoints está em `api/README.md`.
- Schema do banco: `sql/db_autoleitura.sql`.

## Git / CI

- **Commit-msg hook obrigatório**: todo commit precisa de Emoji + Conventional Commit (`<emoji> <tipo>(<escopo>): <descrição>`, tipos: feat/fix/docs/style/refactor/test/chore/build/ci/perf/revert/raw/cleanup/remove). O hook fica em `.githooks/commit-msg` e é ativado via `git config core.hooksPath .githooks` (config local, não versionada). `.scripts/commit.sh` é um helper interativo que monta a mensagem no formato correto e chama `git commit` (use-o em vez de montar manualmente).
- Trabalhar em `develop`/`feature-api` (branch atual do checkout; `feature-api` é idêntica a `develop`). `master` só recebe merge/PR e é **protegida**, mas a exigência de review foi **removida** (repo solo — sem auto-aprovação no GitHub); push/force direto continua bloqueado.
- CI (`.github/workflows/develop.yaml`) dispara em push para `master` (merge da develop), `pull_request` para `master` e `workflow_dispatch`. Não dispara em push para `develop`/`feature-api`. O job Deploy roda apenas em push (merge), não em PR.
- Pipeline: Build (`flutter build apk`, Flutter 3.47.0) → upload de artefato → Deploy (download do APK + email). O job de teste está comentado e **não** roda no CI.
- `.scripts/*.sh` são helpers do CI (Telegram/email).