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
| POST | `/atualizar_usuario` | Atualiza dados de um usuário (admin) |
| POST | `/cadastrar_usuario` | Cadastra um novo usuário (admin) |
| POST | `/postLeituras` | Insere a leitura do mês atual |
| GET | `/leituras` | Lista as leituras do mês atual |
| POST | `/calcular_conta` | Calcula/atualiza a conta do mês do usuário |
| POST | `/exibir_conta` | Lista as contas de um usuário |
| GET | `/listar_conta` | Lista todas as contas |
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

## POST /atualizar_usuario

Atualiza os dados de um usuário existente (uso administrativo). Só altera os campos enviados. `codigo` é obrigatório; os demais são opcionais.

**Body (JSON):**

```json
{"codigo":1,"nome":"Administrador","local":"A","celular":"11999990000","email":"admin@autoleitura.local","role":"admin","senha":"novaSenha"}
```

**Sucesso** (`200`):

```json
{"code":1,"result":[{"id":1,"local":"A","nome":"Administrador","celular":"11999990000","email":"admin@autoleitura.local","role":"admin"}]}
```

**Erros** (`200`):

```json
{"code":0,"message":"Erro nos dados recebidos"}
{"code":0,"message":"Usuário não encontrado"}
{"code":0,"message":"Nome inválido"}
{"code":0,"message":"Local deve ter 1 caractere"}
{"code":0,"message":"Celular inválido (11 dígitos)"}
{"code":0,"message":"Celular já cadastrado para outro usuário"}
{"code":0,"message":"E-mail inválido"}
{"code":0,"message":"E-mail já cadastrado para outro usuário"}
{"code":0,"message":"Role inválido (usuario ou admin)"}
{"code":0,"message":"Senha deve ter pelo menos 6 caracteres"}
{"code":0,"message":"Nenhum campo para atualizar"}
```

Se `senha` for enviada, é gravada com hash bcrypt.

---

## POST /cadastrar_usuario

Cadastra um novo usuário (uso administrativo). `nome`, `local`, `celular` e `senha` são obrigatórios; `email` e `role` opcionais (`role` default `usuario`).

**Body (JSON):**

```json
{"nome":"Fulano","local":"F","celular":"11933334444","email":"fulano@exemplo.com","senha":"fulano@2026","role":"usuario"}
```

**Sucesso** (`200`):

```json
{"code":1,"result":[{"id":7,"local":"F","nome":"Fulano","celular":"11933334444","email":"fulano@exemplo.com","role":"usuario"}]}
```

**Erros** (`200`):

```json
{"code":0,"message":"Erro nos dados recebidos"}
{"code":0,"message":"Nome inválido"}
{"code":0,"message":"Local deve ter 1 caractere"}
{"code":0,"message":"Celular inválido (11 dígitos)"}
{"code":0,"message":"Celular já cadastrado"}
{"code":0,"message":"E-mail inválido"}
{"code":0,"message":"E-mail já cadastrado"}
{"code":0,"message":"Senha deve ter pelo menos 6 caracteres"}
{"code":0,"message":"Role inválido (usuario ou admin)"}
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

## POST /calcular_conta

Calcula a conta do mês atual do usuário: consumo = leitura atual − leitura anterior, multiplicado pelo valor do m³ vigente (`tb_valor`). Insere a conta em `tb_contas` ou **recalcula** se já existir para o usuário/mês (UNIQUE `codigouser` + `mesreferencia`).

**Body (JSON):**

```json
{"codigo":1}
```

**Sucesso:**

```json
{"code":1,"result":[{"codigouser":1,"mesreferencia":"Agosto","leituraatual":62,"leituraanterior":50,"consumo":12,"valormetrocubico":1.15,"valorconta":13.80,"mensagem":"Seu consumo foi de 12 metros cubicos"}]}
```

**Erros** (`200`):

```json
{"code":0,"message":"Erro nos dados recebidos"}
{"code":0,"message":"Usuário não encontrado"}
{"code":0,"message":"Leituras não encontradas para o mês atual ou anterior"}
{"code":0,"message":"Valor do metro cúbico não cadastrado"}
{"code":0,"message":"Erro ao calcular a conta"}
```

---

## POST /exibir_conta

Lista as contas de um usuário (join com `tb_usuarios`).

**Body (JSON):**

```json
{"codigo":1}
```

**Sucesso:**

```json
{"code":1,"result":[{"nome":"Administrador","id":1,"local":"A","mesreferencia":"Agosto","dataemissao":"2026-08-17","datavencimento":"2026-08-27","valorconta":"13.80","valormetrocubico":"1.15","leituraatual":62,"leituraanterior":50,"mensagem":"Seu consumo foi de 12 metros cubicos"}]}
```

**Sem dados / dados inválidos:**

```json
{"code":0,"message":"Data Not Found"}
{"code":0,"message":"Erro nos dados recebidos"}
```

---

## GET /listar_conta

Lista todas as contas (join com `tb_usuarios`).

**Sucesso:**

```json
{"code":1,"result":[{...}]}
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