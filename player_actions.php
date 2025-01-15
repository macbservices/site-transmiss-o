<?php
$servername = "localhost";
$username = "root";
$password = "b18073518B@123";
$dbname = "tvonline";

// Criar conexão
$conn = new mysqli($servername, $username, $password, $dbname);

// Verificar conexão
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Verificar o login do usuário
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $data = json_decode(file_get_contents("php://input"));

    if (isset($data->username) && isset($data->password)) {
        if ($_GET['action'] == 'verify-login') {
            $stmt = $conn->prepare("SELECT * FROM users WHERE username = ? AND password = ?");
            $stmt->bind_param("ss", $data->username, $data->password);
            $stmt->execute();
            $result = $stmt->get_result();

            if ($result->num_rows > 0) {
                echo json_encode(["success" => true]);
            } else {
                echo json_encode(["success" => false]);
            }

            $stmt->close();
        }
    }
}

// Obter o link do stream
if ($_SERVER['REQUEST_METHOD'] == 'GET' && $_GET['action'] == 'get-stream-url') {
    $result = $conn->query("SELECT url FROM video WHERE id = 1");
    $row = $result->fetch_assoc();
    echo json_encode(["url" => $row['url']]);
}

$conn->close();
?>
