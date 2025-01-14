#!/bin/bash

echo "==> Atualizando pacotes..."
sudo apt update && sudo apt upgrade -y

echo "==> Instalando dependências..."
sudo apt install -y apache2 certbot python3-certbot-apache git unzip

echo "==> Configurando Apache..."
sudo mkdir -p /var/www/html
sudo cp -r * /var/www/html/

sudo bash -c 'cat <<EOF > /etc/apache2/sites-available/000-default.conf
<VirtualHost *:80>
    DocumentRoot /var/www/html
    <Directory /var/www/html>
        AllowOverride All
        Require all granted
    </Directory>
    RewriteEngine On
    RewriteCond %{REQUEST_URI} ^/$
    RewriteRule ^ /client-login.html [L]
    <FilesMatch "player.html">
        Require all denied
    </FilesMatch>
</VirtualHost>
EOF'

echo "==> Ativando módulos do Apache..."
sudo a2enmod rewrite
sudo systemctl restart apache2

read -p "Você quer usar um domínio? (s/n): " use_domain

if [[ "$use_domain" == "s" ]]; then
    read -p "Digite o domínio: " domain
    sudo bash -c "echo '127.0.0.1 $domain' >> /etc/hosts"
    sudo certbot --apache -d "$domain"
fi

echo "==> Instalação concluída!"

