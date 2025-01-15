<?php
include 'db_config.php';

if (isset($_GET['action'])) {
    $action = $_GET['action'];

    if ($action == "loadUsers") {
        $result = $conn->query("SELECT username FROM users");
        $users = [];
        while ($row = $result->fetch_assoc()) {
            $users[] = $row;
        }
        echo json_encode($users);
    }

    if ($action == "editUser" && isset($_POST['username']) && isset($_POST['password'])) {
        $username = $_POST['username'];
        $password = password_hash($_POST['password'], PASSWORD_DEFAULT);

        $stmt = $conn->prepare("UPDATE users SET password = ? WHERE username = ?");
        $stmt->bind_param("ss", $password, $username);
        if ($stmt->execute()) {
            echo "Password updated successfully!";
        } else {
            echo "Error: " . $stmt->error;
        }

        $stmt->close();
    }

    if ($action == "deleteUser" && isset($_POST['username'])) {
        $username = $_POST['username'];
        $stmt = $conn->prepare("DELETE FROM users WHERE username = ?");
        $stmt->bind_param("s", $username);
        if ($stmt->execute()) {
            echo "User deleted successfully!";
        } else {
            echo "Error: " . $stmt->error;
        }
        $stmt->close();
    }
}

$conn->close();
?>
