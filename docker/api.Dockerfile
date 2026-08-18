FROM php:8.4-apache

# Driver MySQL (PDO) + rewrite (usado pelo .htaccess da API)
RUN docker-php-ext-install pdo_mysql \
    && a2enmod rewrite headers \
    && sed -ri -e 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf

# Gera api/conexao/env.php a partir das variáveis de ambiente (MYSQL_*)
COPY docker/api-entrypoint.sh /usr/local/bin/api-entrypoint.sh
RUN chmod +x /usr/local/bin/api-entrypoint.sh

EXPOSE 80
ENTRYPOINT ["api-entrypoint.sh"]
CMD ["apache2-foreground"]