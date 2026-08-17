-- ============================================================================
-- AutoLeitura - Verificação de sanidade do banco
-- Executar DEPOIS de aplicar db_autoleitura.sql.
-- Queries de "esperado: vazio" NÃO devem retornar linhas num banco saudável.
-- ============================================================================

USE db_autoleitura;

-- 1. Duplicatas em tb_usuarios
SELECT '1a. celular duplicado (esperado: vazio)' AS verif;
SELECT celular, COUNT(*) AS qtde
FROM tb_usuarios
GROUP BY celular
HAVING COUNT(*) > 1;

SELECT '1b. email duplicado (esperado: vazio)' AS verif;
SELECT email, COUNT(*) AS qtde
FROM tb_usuarios
GROUP BY email
HAVING COUNT(*) > 1;

-- 2. Duplicatas em tb_leituras (codigo + mes)
SELECT '2. leitura duplicada por usuario/mes (esperado: vazio)' AS verif;
SELECT codigo, mes, COUNT(*) AS qtde
FROM tb_leituras
GROUP BY codigo, mes
HAVING COUNT(*) > 1;

-- 3. Duplicatas em tb_contas (codigouser + mesreferencia)
SELECT '3. conta duplicada por usuario/mes (esperado: vazio)' AS verif;
SELECT codigouser, mesreferencia, COUNT(*) AS qtde
FROM tb_contas
GROUP BY codigouser, mesreferencia
HAVING COUNT(*) > 1;

-- 4. Órfãos de FK (leituras/contas apontando para usuário inexistente)
SELECT '4a. leituras sem usuario (esperado: vazio)' AS verif;
SELECT l.id, l.codigo
FROM tb_leituras l
LEFT JOIN tb_usuarios u ON l.codigo = u.id
WHERE u.id IS NULL;

SELECT '4b. contas sem usuario (esperado: vazio)' AS verif;
SELECT c.id, c.codigouser
FROM tb_contas c
LEFT JOIN tb_usuarios u ON c.codigouser = u.id
WHERE u.id IS NULL;

-- 5. Integridade das tabelas
SELECT '5. CHECK TABLE (esperado: status OK)' AS verif;
CHECK TABLE tb_usuarios, tb_leituras, tb_valor, tb_contas;

-- 6. Consistência de valores
SELECT '6a. leitura negativa (esperado: vazio)' AS verif;
SELECT id, codigo, mes, leitura
FROM tb_leituras
WHERE leitura < 0;

SELECT '6b. conta com leituraatual < leituraanterior (esperado: vazio)' AS verif;
SELECT id, codigouser, leituraatual, leituraanterior
FROM tb_contas
WHERE leituraatual < leituraanterior;

SELECT '6c. valorconta divergente de consumo * m3 (esperado: vazio)' AS verif;
SELECT id, codigouser, valorconta,
       ROUND((leituraatual - leituraanterior) * valormetrocubico, 2) AS esperado
FROM tb_contas
WHERE valorconta <> ROUND((leituraatual - leituraanterior) * valormetrocubico, 2);

-- 7. Resumo de contagens
SELECT '7. contagens por tabela' AS verif;
SELECT 'tb_usuarios' AS tabela, COUNT(*) AS qtde FROM tb_usuarios
UNION ALL SELECT 'tb_leituras', COUNT(*) FROM tb_leituras
UNION ALL SELECT 'tb_valor', COUNT(*) FROM tb_valor
UNION ALL SELECT 'tb_contas', COUNT(*) FROM tb_contas;

-- 8. Distribuição por papel
SELECT '8. usuarios por role' AS verif;
SELECT role, COUNT(*) AS qtde
FROM tb_usuarios
GROUP BY role;