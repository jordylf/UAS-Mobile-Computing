<?php
require_once '../config/database.php';

$data = json_decode(file_get_contents("php://input"));

if (!empty($data->id) && (!empty($data->fullname) || !empty($data->email) || !empty($data->password))) {
    $db = new Database();
    $conn = $db->getConnection();

    // Mengambil data user berdasarkan ID untuk memastikan apakah user ada
    $check_query = "SELECT * FROM users WHERE id = ?";
    $stmt = $conn->prepare($check_query);
    $stmt->bind_param('i', $data->id);
    $stmt->execute();
    $check_result = $stmt->get_result();

    if ($check_result->num_rows == 0) {
        $response = array(
            'status' => 'error',
            'message' => 'User not found'
        );
        http_response_code(404);
    } else {
        // Jika ada perubahan pada email, cek apakah email baru sudah digunakan oleh user lain
        if (!empty($data->email)) {
            $email_check_query = "SELECT * FROM users WHERE email = ? AND id != ?";
            $stmt = $conn->prepare($email_check_query);
            $stmt->bind_param('si', $data->email, $data->id);
            $stmt->execute();
            $email_check_result = $stmt->get_result();

            if ($email_check_result->num_rows > 0) {
                $response = array(
                    'status' => 'error',
                    'message' => 'Email already exists'
                );
                http_response_code(409);
            } else {
                // Update query, hanya mengupdate yang dikirimkan
                $update_query = "UPDATE users SET fullname = ?, email = ?";

                // Jika password diisi, kita akan mengupdate passwordnya
                if (!empty($data->password)) {
                    $password = password_hash($data->password, PASSWORD_BCRYPT);
                    $update_query .= ", password = ?";
                }

                // Menyelesaikan query
                $update_query .= " WHERE id = ?";
                $stmt = $conn->prepare($update_query);

                // Menentukan parameter yang diikatkan pada query
                if (!empty($data->password)) {
                    $stmt->bind_param('sssi', $data->fullname, $data->email, $password, $data->id);
                } else {
                    $stmt->bind_param('ssi', $data->fullname, $data->email, $data->id);
                }

                if ($stmt->execute()) {
                    $response = array(
                        'status' => 'success',
                        'message' => 'User updated successfully'
                    );
                    http_response_code(200);
                } else {
                    $response = array(
                        'status' => 'error',
                        'message' => 'Unable to update user'
                    );
                    http_response_code(500);
                }
            }
        } else {
            // Update hanya fullname atau password
            $update_query = "UPDATE users SET fullname = ?";

            // Jika password diisi, update passwordnya
            if (!empty($data->password)) {
                $password = password_hash($data->password, PASSWORD_BCRYPT);
                $update_query .= ", password = ?";
            }

            $update_query .= " WHERE id = ?";
            $stmt = $conn->prepare($update_query);

            // Menentukan parameter yang diikatkan pada query
            if (!empty($data->password)) {
                $stmt->bind_param('ssi', $data->fullname, $password, $data->id);
            } else {
                $stmt->bind_param('si', $data->fullname, $data->id);
            }

            if ($stmt->execute()) {
                $response = array(
                    'status' => 'success',
                    'message' => 'User updated successfully'
                );
                http_response_code(200);
            } else {
                $response = array(
                    'status' => 'error',
                    'message' => 'Unable to update user'
                );
                http_response_code(500);
            }
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
