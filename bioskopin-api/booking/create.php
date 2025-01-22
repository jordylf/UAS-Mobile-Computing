<?php
require_once '../config/database.php';

// Mendapatkan data dari input JSON
$data = json_decode(file_get_contents("php://input"));

// Validasi input
if (
    !empty($data->film_id) &&
    !empty($data->quantity) &&
    !empty($data->user_id) &&
    is_numeric($data->film_id) &&
    is_numeric($data->quantity) &&
    is_numeric($data->user_id)
) {
    $db = new Database();
    $conn = $db->getConnection();

    $film_id = $data->film_id;
    $quantity = $data->quantity;
    $user_id = $data->user_id;

    // Cek apakah user valid
    $check_user_query = "SELECT id FROM users WHERE id = ?";
    $stmt = $conn->prepare($check_user_query);
    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $user_result = $stmt->get_result();

    if ($user_result->num_rows > 0) {
        // Cek apakah film tersedia
        $check_film_query = "SELECT id, price FROM film WHERE id = ?";
        $stmt = $conn->prepare($check_film_query);
        $stmt->bind_param("i", $film_id);
        $stmt->execute();
        $film_result = $stmt->get_result();

        if ($film_result->num_rows > 0) {
            // data film
            $film_data = $film_result->fetch_object();

            $price_total = $film_data->price * $quantity;

            // Lakukan booking jika film tersedia dan user valid
            $insert_query = "INSERT INTO booking (user_id, film_id, ticket_quantity, total_price, status) VALUES (?, ?, ?, ?, 'pending')";

            $stmt = $conn->prepare($insert_query);
            $stmt->bind_param("iiid", $user_id, $film_id, $quantity, $price_total);

            if ($stmt->execute()) {
                $response = array(
                    'status' => 'success',
                    'message' => 'Booking created successfully'
                );
                http_response_code(201);
            } else {
                $response = array(
                    'status' => 'error',
                    'message' => 'Unable to create booking. Please try again later.'
                );
                http_response_code(500);
            }
        } else {
            // Jika film tidak ditemukan
            $response = array(
                'status' => 'error',
                'message' => 'Film not found'
            );
            http_response_code(404);
        }
    } else {
        // Jika user tidak valid
        $response = array(
            'status' => 'error',
            'message' => 'User not found'
        );
        http_response_code(404);
    }

    // Tutup statement dan koneksi
    $stmt->close();
    $conn->close();
} else {
    // Jika data tidak lengkap atau tidak valid
    $response = array(
        'status' => 'error',
        'message' => 'Incomplete or invalid data'
    );
    http_response_code(400);
}

// Kirimkan response dalam format JSON
header('Content-Type: application/json');
echo json_encode($response);
