#!/bin/sh
set -e

# Gera conexao/env.php a partir das envs do compose
# (conn.php faz include relativo e resolve pelo diretório do próprio script)
cat > /var/www/html/conexao/env.php <<EOF
<?php
\$host = '${MYSQL_HOST:-db}';
\$banco = '${MYSQL_DATABASE:-db_autoleitura}';
\$user = '${MYSQL_USER:-autoleitura}';
\$senha = '${MYSQL_PASSWORD:-autoleitura}';
?>
EOF

# Apache roda como www-data: garante escrita do logs.log (volume nomeado)
mkdir -p /var/www/html/logs
chown -R www-data:www-data /var/www/html/logs

exec "$@"