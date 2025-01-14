#!/bin/bash

# Configurações iniciais
SITE_DIR="/var/www/html"
REPO_URL="https://raw.githubusercontent.com/macbservices/site-transmissao/main"

# Atualizar o sistema
echo "Atualizando pacotes..."
sudo apt update && sudo apt upgrade -y

# Instalar dependências
echo "Instalando Apache, Certbot e outras dependências..."
sudo apt install apache2 curl certbot python3-certbot-apache unzip -y

# Configurar o Apache
echo "Configurando o Apache..."
sudo a2enmod ssl rewrite
sudo systemctl restart apache2

# Baixar arquivos do site
echo "Baixando arquivos do site..."
sudo mkdir -p $SITE_DIR
sudo curl -o $SITE_DIR/admin-panel.html $REPO_URL/admin-panel.html
sudo curl -o $SITE_DIR/client-login.html $REPO_URL/client-login.html
sudo curl -o $SITE_DIR/player.html $REPO_URL/player.html
sudo curl -o $SITE_DIR/config.php $REPO_URL/config.php
sudo curl -o $SITE_DIR/styles.css $REPO_URL/styles.css

# Configurar permissões
echo "Configurando permissões..."
sudo chown -R www-data:www-data $SITE_DIR
sudo chmod -R 755 $SITE_DIR

# Adicionar configuração para garantir acesso ao diretório
sudo sed -i '/<Directory \/var\/www\/html>/,/<\/Directory>/c\\
<Directory /var/www/html>\\n    AllowOverride All\\n    Require all granted\\n<\/Directory>' /etc/apache2/sites-available/000-default.conf

# Configurar SSL e domínio
read -p "Você deseja configurar um domínio com SSL? (y/n): " ssl_option
if [[ "$ssl_option" == "y" ]]; then
    read -p "Digite o domínio (ex: exemplo.com): " domain

    # Configuração do VirtualHost
    echo "Criando configuração para o domínio $domain..."
    sudo cat > /etc/apache2/sites-available/$domain.conf <<EOL
<VirtualHost *:80>
    ServerName $domain
    ServerAlias www.$domain
    DocumentRoot $SITE_DIR

    <Directory $SITE_DIR>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined

    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
</VirtualHost>

<IfModule mod_ssl.c>
    <VirtualHost *:443>
        ServerName $domain
        ServerAlias www.$domain
        DocumentRoot $SITE_DIR

        <Directory $SITE_DIR>
            AllowOverride All
            Require all granted
        </Directory>

        ErrorLog \${APACHE_LOG_DIR}/error.log
        CustomLog \${APACHE_LOG_DIR}/access.log combined

        SSLEngine on
        SSLCertificateFile /etc/letsencrypt/live/$domain/fullchain.pem
        SSLCertificateKeyFile /etc/letsencrypt/live/$domain/privkey.pem
    </VirtualHost>
</IfModule>
EOL

    # Habilitar site e obter certificado SSL
    sudo a2ensite $domain
    sudo systemctl reload apache2
    sudo certbot --apache -d $domain -d www.$domain
else
    echo "SSL não configurado. Você pode configurar manualmente depois."
fi

# Reiniciar Apache
echo "Reiniciando o Apache..."
sudo systemctl restart apache2

# Finalização
echo "Instalação concluída! Acesse o site pelo IP ou domínio configurado."
