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

// Criação do usuário
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $data = json_decode(file_get_contents("php://input"));

    if (isset($data->username) && isset($data->password)) {
        if ($data->action == 'create-user') {
            $stmt = $conn->prepare("INSERT INTO users (username, password) VALUES (?, ?)");
            $stmt->bind_param("ss", $data->username, $data->password);
            if ($stmt->execute()) {
                echo json_encode(["success" => true]);
            } else {
                echo json_encode(["success" => false]);
            }
            $stmt->close();
        }

        if ($data->action == 'edit-user') {
            $stmt = $conn->prepare("UPDATE users SET password = ? WHERE username = ?");
            $stmt->bind_param("ss", $data->password, $data->username);
            $stmt->execute();
            echo json_encode(["success" => true]);
            $stmt->close();
        }

        if ($data->action == 'delete-user') {
            $stmt = $conn->prepare("DELETE FROM users WHERE username = ?");
            $stmt->bind_param("s", $data->username);
            $stmt->execute();
            echo json_encode(["success" => true]);
            $stmt->close();
        }

        if ($data->action == 'update-video') {
            $stmt = $conn->prepare("UPDATE video SET url = ? WHERE id = 1");
            $stmt->bind_param("s", $data->url);
            $stmt->execute();
            echo json_encode(["success" => true]);
            $stmt->close();
        }
    }
}

// Listar usuários
if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    if ($_GET['action'] == 'get-users') {
        $result = $conn->query("SELECT * FROM users");
        $users = [];
        while ($row = $result->fetch_assoc()) {
            $users[] = $row;
        }
        echo json_encode($users);
    }

    if ($_GET['action'] == 'get-video-url') {
        $result = $conn->query("SELECT url FROM video WHERE id = 1");
        $row = $result->fetch_assoc();
        echo json_encode(["url" => $row['url']]);
    }
}

$conn->close();
?>
