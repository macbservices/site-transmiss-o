<?php
// Configuração do banco de dados
$servername = "localhost";
$username = "root";
$password = "b18073518B@123";
$dbname = "tvonline";

// Conexão ao banco de dados
$conn = new mysqli($servername, $username, $password, $dbname);

// Verifica se a conexão foi bem-sucedida
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Recebe os dados de login
$user = $_POST['username'];
$pass = $_POST['password'];

// Valida o usuário e a senha no banco de dados
$sql = "SELECT * FROM users WHERE username = ? AND password = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("ss", $user, $pass);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    // Usuário encontrado
    session_start();
    $_SESSION['username'] = $user;
    echo "Login bem-sucedido!";
} else {
    // Usuário ou senha incorretos
    echo "Usuário ou senha incorretos!";
}

$stmt->close();
$conn->close();
?>
