#!/bin/bash

# Verifica se o script está sendo executado como root
if [ "$(id -u)" -ne 0 ]; then
  echo "Este script precisa ser executado como root. Use sudo ./install.sh"
  exit 1
fi

echo "Atualizando pacotes..."
apt update -y && apt upgrade -y

echo "Instalando dependências..."
apt install -y apache2 git curl unzip

echo "Habilitando o Apache para iniciar automaticamente..."
systemctl enable apache2
systemctl start apache2

echo "Clonando repositório do site..."
REPO_URL="https://github.com/macbservices/site-transmissao.git"
WEB_DIR="/var/www/tvonline"
if [ -d "$WEB_DIR" ]; then
  rm -rf "$WEB_DIR"
fi
git clone "$REPO_URL" "$WEB_DIR"

echo "Configurando permissões..."
chown -R www-data:www-data "$WEB_DIR"
chmod -R 755 "$WEB_DIR"

echo "Configurando o Apache..."
APACHE_CONF="/etc/apache2/sites-available/tvonline.conf"
cat <<EOL > $APACHE_CONF
<VirtualHost *:80>
    ServerAdmin admin@tvonline.local
    DocumentRoot $WEB_DIR
    <Directory $WEB_DIR>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/tvonline_error.log
    CustomLog \${APACHE_LOG_DIR}/tvonline_access.log combined
</VirtualHost>
EOL

a2ensite tvonline.conf
a2dissite 000-default.conf
systemctl reload apache2

echo "Instalação do site concluída! O site está disponível em: http://$(curl -s ifconfig.me)"

# Perguntar se deseja configurar um domínio
read -p "Você deseja adicionar um domínio ao site? (sim/não): " ADD_DOMAIN
if [[ "$ADD_DOMAIN" == "sim" ]]; then
  read -p "Informe o domínio (ex.: seusite.com): " DOMINIO

  echo "Configurando domínio: $DOMINIO..."

  # Atualiza o VirtualHost do Apache
  cat <<EOL > $APACHE_CONF
<VirtualHost *:80>
    ServerAdmin admin@$DOMINIO
    ServerName $DOMINIO
    ServerAlias www.$DOMINIO
    DocumentRoot $WEB_DIR
    <Directory $WEB_DIR>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/tvonline_error.log
    CustomLog \${APACHE_LOG_DIR}/tvonline_access.log combined
</VirtualHost>
EOL

  a2ensite tvonline.conf
  systemctl reload apache2

  echo "Instalando Certbot para configurar SSL..."
  apt install -y certbot python3-certbot-apache
  certbot --apache -d $DOMINIO -d www.$DOMINIO --non-interactive --agree-tos -m admin@$DOMINIO

  echo "Configurando renovação automática de certificados..."
  (crontab -l 2>/dev/null; echo "0 0 * * * certbot renew --quiet") | crontab -

  echo "Configuração de domínio concluída! O site está disponível em: https://$DOMINIO"
fi
