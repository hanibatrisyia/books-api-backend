FROM php:8.2-apache
RUN docker-php-ext-install pdo_mysql
RUN a2enmod rewrite
COPY . /var/www/html
RUN sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf
RUN echo '<Directory /var/www/html/public>\n\
    Options Indexes FollowSymLinks\n\
    AllowOverride All\n\
    Require all granted\n\
    \n\
    # Inject CORS Headers Globally for your live Vercel link\n\
    SetEnvIf Origin "https://books-frontend-ace-code.vercel.app" AccessControlAllowOrigin=$0\n\
    Header set Access-Control-Allow-Origin %{AccessControlAllowOrigin}e env=AccessControlAllowOrigin\n\
    Header set Access-Control-Allow-Headers "X-Requested-With, Content-Type, Accept, Origin, Authorization"\n\
    Header set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"\n\
    Header set Access-Control-Allow-Credentials "true"\n\
</Directory>' >> /etc/apache2/apache2.conf