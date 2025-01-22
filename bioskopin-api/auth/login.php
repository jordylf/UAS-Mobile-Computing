<?php
require_once '../config/database.php';

$data = json_decode(file_get_contents("php://input"));

if (!empty($data->email) && !empty($data->password)) {
    $db = new Database();
    $conn = $db->getConnection();

    // Gunakan prepared statement untuk mencegah SQL Injection
    $query = "SELECT * FROM users WHERE email = ?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param('s', $data->email);
    $stmt->execute();
    $result = $stmt->get_result();
    $user = $result->fetch_assoc();

    if ($user && password_verify($data->password, $user['password'])) {
        // Filter data sebelum dikirim ke klien
        $response = array(
            'status' => 'success',
            'message' => 'Login successful',
            'data' => array(
                'userId' => htmlspecialchars($user['id']),
                'fullname' => htmlspecialchars($user['fullname']),
                'email' => htmlspecialchars($user['email']),
                'role' => htmlspecialchars($user['role'])
            )
        );

        http_response_code(200);
    } else {
        $response = array(
            'status' => 'error',
            'message' => 'Invalid email or password'
        );
        http_response_code(401);
    }

    $stmt->close();
    $conn->close();
} else {
    $response = array(
        'status' => 'error',
        'message' => 'Incomplete data'
    );
    http_response_code(400);
}

header('Content-Type: application/json');
echo json_encode($response);
