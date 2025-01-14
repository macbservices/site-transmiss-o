#!/bin/bash

# Configuração do diretório do site
SITE_DIR="/var/www/html"
REPO_URL="https://raw.githubusercontent.com/macbservices/site-transmissao/main"

# Atualizar o sistema
echo "Atualizando pacotes..."
sudo apt update && sudo apt upgrade -y

# Instalar dependências necessárias
echo "Instalando Apache, Certbot e outras dependências..."
sudo apt install apache2 curl certbot python3-certbot-apache unzip -y

# Baixar arquivos do site
echo "Baixando arquivos do site..."
sudo mkdir -p $SITE_DIR
sudo curl -o $SITE_DIR/admin-panel.html $REPO_URL/admin-panel.html
sudo curl -o $SITE_DIR/client-login.html $REPO_URL/client-login.html
sudo curl -o $SITE_DIR/player.html $REPO_URL/player.html

# Configurar permissões
echo "Configurando permissões do diretório do site..."
sudo chown -R www-data:www-data $SITE_DIR
sudo chmod -R 755 $SITE_DIR

# Perguntar sobre configuração de domínio e SSL
read -p "Você deseja configurar um domínio com SSL? (y/n): " ssl_option
if [[ "$ssl_option" == "y" ]]; then
    read -p "Digite o domínio (ex: exemplo.com): " domain
    sudo certbot --apache -d $domain
    echo "SSL configurado para o domínio $domain"
else
    echo "SSL não configurado. Você pode configurar manualmente depois."
fi

# Reiniciar Apache
echo "Reiniciando o Apache..."
sudo systemctl restart apache2

# Finalização
echo "Instalação concluída! Acesse o site pelo IP ou domínio configurado."
