<?php
// Configuração do banco de dados
$servername = "localhost";
$username = "root"; // Alterar se necessário
$password = ""; // Alterar se necessário
$dbname = "tv_online"; // Nome do banco de dados

// Criação da conexão
$conn = new mysqli($servername, $username, $password, $dbname);

// Verifica a conexão
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Recebe os dados do formulário
if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $clientUsername = $_POST['clientUsername'];
    $clientPassword = $_POST['clientPassword'];

    // Criptografa a senha
    $hashedPassword = password_hash($clientPassword, PASSWORD_DEFAULT);

    // Verifica se o usuário já existe
    $checkUserQuery = "SELECT * FROM users WHERE username = ?";
    $stmt = $conn->prepare($checkUserQuery);
    $stmt->bind_param("s", $clientUsername);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows > 0) {
        echo "Username already exists!";
    } else {
        // Insere o novo usuário no banco de dados
        $insertUserQuery = "INSERT INTO users (username, password) VALUES (?, ?)";
        $stmt = $conn->prepare($insertUserQuery);
        $stmt->bind_param("ss", $clientUsername, $hashedPassword);

        if ($stmt->execute()) {
            echo "Client user created successfully!";
        } else {
            echo "Error: " . $stmt->error;
        }
    }

    $stmt->close();
}

$conn->close();
?>
