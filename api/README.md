# AutoLeitura API

API PHP (sem framework) do app AutoLeitura. Roteamento: `.htaccess` → `index.php` → `Router.php` → `RouteSwitch.php` → `endpoints/**`. A rota `/x` chama o método `x()` no `RouteSwitch` (ex.: `/login` → `login()`).

- Base URL: `https://api.autoleitura.online`
- Formato de resposta: `{"code":0|1, ...}` — `code:1` = sucesso (campo `result`), `code:0` = erro (campo `message`).
  - **Exceção**: `/postLeituras` usa `code:0` como sucesso.
- Respostas JSON são unicode-escaped (padrão `json_encode` do PHP; ex.: `\u00e3` para "ã").

## Endpoints

| Método | Rota | Descrição |
| --- | --- | --- |
| GET | `/usuario` | Lista todos os usuários (sem senha) |
| POST | `/login` | Login por código + senha (bcrypt) |
| POST | `/postLeituras` | Insere a leitura do mês atual |
| GET | `/leituras` | Lista as leituras do mês atual |
| GET | `/home` | Página HTML de documentação (requer HTTP Basic Auth) |
| GET | `/admin` | Logs brutos da API (`logs.log` — só existe em produção) |

---

## GET /usuario

Lista todos os usuários. **Nunca** retorna a coluna `senha`.

**Sucesso** (`200`):

```json
{"code":1,"result":[{"id":1,"local":"A","nome":"Administrador","celular":"11999990000","email":"admin@autoleitura.local","role":"admin"}]}
```

**Sem dados**:

```json
{"code":0,"message":"Data Not Found"}
```

---

## POST /login

Login do usuário pelo código (`id`) + senha. Valida a senha com `password_verify` (bcrypt).

**Body (JSON):**

```json
{"codigo":1,"senha":"admin@2026DB"}
```

**Sucesso** (`200`):

```json
{"code":1,"result":[{"id":1,"local":"A","nome":"Administrador","celular":"11999990000","email":"admin@autoleitura.local","role":"admin"}]}
```

`role`: `"admin"` ou `"usuario"`. A coluna `senha` nunca é retornada.

**Erros** (`200`):

```json
{"code":0,"message":"Erro nos dados recebidos"}
{"code":0,"message":"Usuário não encontrado"}
{"code":0,"message":"Senha incorreta"}
```

---

## POST /postLeituras

Insere a leitura do mês atual do usuário ou **atualiza** se já existir (upsert pelo UNIQUE `codigo` + `mes`). **Atenção**: sucesso usa `code:0`.

**Body (JSON):**

```json
{"codigo":1,"leitura":62}
```

**Sucesso (inseriu ou atualizou):**

```json
{"code":0,"message":"Leitura inserida com sucesso para o usuario codigo:1 no mes: Agosto"}
```

**Erros** (`200`):

```json
{"code":0,"message":"Erro nos dados recebidos"}
{"code":0,"message":"Usuário não encontrado"}
{"code":1,"message":"Erro ao inserir leitura para o usuario codigo:1 na data -->..."}
```

---

## GET /leituras

Lista as leituras do mês atual (usa `$mesAtual` de `api/date.php`).

**Sucesso**:

```json
{"code":1,"result":[{"id":1,"mes":"Agosto","leitura":62,"data":"2026-08-15","codigo":1}]}
```

**Sem dados:**

```json
{"code":0,"message":"Data Not Found"}
```

---

## GET /home

Página HTML de documentação. Requer HTTP Basic Auth (variáveis `PHP_AUTH_USER`/`PHP_AUTH_PW`), configuradas no servidor.

## GET /admin

Expõe o conteúdo bruto de `api/logs/logs.log`. Só responde quando o arquivo existe no servidor (é gitignored).

---

## Endpoints existentes, ainda não roteados

Os arquivos em `api/endpoints/contas/` (`calcular_conta.php`, `exibir_conta.php`, `listar_conta.php`) existem, mas **não há método correspondente no `RouteSwitch`**, então as rotas `/calcular_conta`, `/exibir_conta` e `/listar_conta` retornam 404. Serão expostos quando os endpoints de conta entrarem no roteador.