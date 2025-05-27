FROM php:7.4-apache

# Set ServerName to suppress Apache warning
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Enable Apache modules
RUN a2enmod rewrite

# Install MySQL extension
RUN docker-php-ext-install mysqli

# Set working directory
WORKDIR /var/www/html

# Copy application files
COPY . .

# Set proper file permissions
RUN chown -R www-data:www-data /var/www/html \
    && find /var/www/html -type d -exec chmod 755 {} \; \
    && find /var/www/html -type f -exec chmod 644 {} \;

# Ensure index.php is used as default DirectoryIndex
RUN echo "<IfModule dir_module>\n    DirectoryIndex index.php index.html\n</IfModule>" > /etc/apache2/conf-available/dirindex.conf \
    && a2enconf dirindex

EXPOSE 80

CMD ["apache2-foreground"]
