FROM php:8.2-apache

# 1. Install the PDO MySQL extension required for your database connection
RUN docker-php-ext-install pdo_mysql

# 2. Enable Apache mod_rewrite module for Slim's routing framework
RUN a2enmod rewrite

# 3. Copy your backend application code into the server directory container
COPY . /var/www/html

# 4. Update Apache's default configuration settings to point its site root directly to public/
RUN sed -i 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf

# 5. Overwrite the main Apache configuration file directory blocks to allow .htaccess overrides
RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/c\\\
<Directory /var/www/html/public>\n\
    Options Indexes FollowSymLinks\n\
    AllowOverride All\n\
    Require all granted\n\
<\/Directory>' /etc/apache2/apache2.conf