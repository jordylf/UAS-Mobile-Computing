<?php
require_once '../config/database.php';

$data = json_decode(file_get_contents("php://input"));

if (!empty($data->fullname) && !empty($data->email) && !empty($data->password)) {
    $db = new Database();
    $conn = $db->getConnection();

    // Gunakan prepared statement untuk keamanan
    $check_query = "SELECT * FROM users WHERE email = ?";
    $stmt = $conn->prepare($check_query);
    $stmt->bind_param('s', $data->email);
    $stmt->execute();
    $check_result = $stmt->get_result();

    if ($check_result->num_rows > 0) {
        $response = array(
            'status' => 'error',
            'message' => 'Email already exists'
        );

        http_response_code(409);
    } else {
        $insert_query = "INSERT INTO users (fullname, email, password, role) VALUES (?, ?, ?, 'user')";
        $stmt = $conn->prepare($insert_query);
        $password = password_hash($data->password, PASSWORD_BCRYPT);
        $stmt->bind_param('sss', $data->fullname, $data->email, $password);

        if ($stmt->execute()) {
            $response = array(
                'status' => 'success',
                'message' => 'User registered successfully'
            );
            http_response_code(201);
        } else {
            $response = array(
                'status' => 'error',
                'message' => 'Unable to register user'
            );
            http_response_code(500);
        }
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
