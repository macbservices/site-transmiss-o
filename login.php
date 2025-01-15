<?php
// Conectar ao banco de dados MySQL
$servername = "localhost";
$username = "root"; // Pode ser alterado se necessário
$password = "b18073518B@123"; // Senha do MySQL
$dbname = "tvonline";

// Criar conexão
$conn = new mysqli($servername, $username, $password, $dbname);

// Verificar conexão
if ($conn->connect_error) {
    die("Conexão falhou: " . $conn->connect_error);
}

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Recebe o usuário e senha do formulário
    $user = $_POST['username'];
    $pass = $_POST['password'];

    // Consulta para verificar o usuário e senha no banco
    $sql = "SELECT * FROM users WHERE username = ? AND password = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ss", $user, $pass);
    $stmt->execute();
    $result = $stmt->get_result();

    if ($result->num_rows > 0) {
        // Usuário encontrado, login bem-sucedido
        session_start();
        $_SESSION['username'] = $user;
        echo "Login bem-sucedido!";
        // Redirecionar para a página do player
        header("Location: player.html");
    } else {
        // Usuário ou senha incorretos
        echo "Usuário ou senha incorretos!";
    }

    $stmt->close();
}

$conn->close();
?>
