#!/bin/bash

# Função para obter o nome de usuário e senha do MySQL
get_mysql_credentials() {
    echo "Digite o nome de usuário do MySQL:"
    read mysql_user
    echo "Digite a senha do MySQL:"
    read -s mysql_password

    # Testa a conexão ao MySQL com as credenciais fornecidas
    mysql -u $mysql_user -p$mysql_password -e "exit" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "Conexão com o MySQL bem-sucedida!"
    else
        echo "Erro ao conectar ao MySQL com o usuário e senha fornecidos. Tente novamente."
        get_mysql_credentials
    fi
}

# Função para obter nome do banco de dados
get_db_name() {
    echo "Digite o nome do banco de dados que deseja criar (exemplo: tv_online):"
    read db_name
}

# Função para criar o arquivo db_config.php
generate_db_config() {
    echo "Gerando o arquivo db_config.php com as configurações fornecidas..."

    cat <<EOL > db_config.php
<?php
\$servername = "localhost";
\$username = "$mysql_user";  // Nome de usuário do MySQL fornecido
\$password = "$mysql_password"; // Senha do MySQL fornecida
\$dbname = "$db_name"; // Nome do banco de dados fornecido

\$conn = new mysqli(\$servername, \$username, \$password, \$dbname);

if (\$conn->connect_error) {
    die("Connection failed: " . \$conn->connect_error);
}
?>
EOL
}

# Atualizar repositórios
echo "Atualizando repositórios do sistema..."
sudo apt update -y

# Instalar Apache, PHP e dependências do MySQL
echo "Instalando Apache, PHP e dependências do MySQL..."
sudo apt install apache2 php libapache2-mod-php php-mysqli -y

# Instalar MySQL
echo "Instalando o MySQL..."
sudo apt install mysql-server -y

# Iniciar e habilitar o MySQL
echo "Iniciando o MySQL..."
sudo systemctl start mysql
sudo systemctl enable mysql

# Solicitar credenciais do MySQL
get_mysql_credentials

# Solicitar nome do banco de dados
get_db_name

# Criar o banco de dados
echo "Criando o banco de dados '$db_name'..."
mysql -u $mysql_user -p$mysql_password -e "CREATE DATABASE IF NOT EXISTS $db_name;"

# Criar a tabela de usuários
echo "Criando a tabela de usuários..."
mysql -u $mysql_user -p$mysql_password -D $db_name -e "
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL
);"

# Gerar o arquivo db_config.php com as credenciais fornecidas
generate_db_config

# Concluir a configuração
echo "Configuração concluída com sucesso! O banco de dados '$db_name' foi criado e o arquivo db_config.php foi gerado com as configurações."

# Informar o usuário que a configuração foi bem-sucedida
echo "Lembre-se de usar o nome de usuário '$mysql_user' e a senha fornecida para configurar sua conexão no site."
