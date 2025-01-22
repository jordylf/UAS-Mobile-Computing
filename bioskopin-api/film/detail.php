<?php
require_once '../config/database.php';

// Memastikan id ada dalam query string
if (isset($_GET['id']) && is_numeric($_GET['id'])) {
    $id = $_GET['id'];  // Mendapatkan id film dari query string
    $db = new Database();
    $conn = $db->getConnection();

    // Gunakan prepared statement untuk keamanan
    $query = "SELECT id, title, genre, price, duration, description, image, showtime FROM film WHERE id = ?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param('i', $id);
    $stmt->execute();
    $result = $stmt->get_result();

    // Mengecek apakah data ditemukan
    if ($result->num_rows > 0) {
        $protocol = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
        $host = $_SERVER['HTTP_HOST'];
        $baseUrl = "$protocol://$host/bioskopin-api/uploads/";

        // Ambil hasil sebagai objek
        $row = $result->fetch_assoc();

        // Menambahkan URL lengkap untuk gambar
        $row['image'] = $baseUrl . htmlspecialchars($row['image']);
        $row['title'] = htmlspecialchars($row['title']);
        $row['description'] = htmlspecialchars($row['description']);
        $row['genre'] = htmlspecialchars($row['genre']);
        $row['price'] = htmlspecialchars($row['price']);
        $row['duration'] = htmlspecialchars($row['duration']);
        $row['showtime'] = htmlspecialchars($row['showtime']);

        // Membuat objek untuk data film
        $movie = (object) $row;

        // Mengirimkan data film dalam format JSON
        $response = array(
            'status' => 'success',
            'data' => $movie // Kirim sebagai objek tunggal
        );

        http_response_code(200);
    } else {
        // Jika film tidak ditemukan
        $response = array(
            'status' => 'error',
            'message' => 'Film not found'
        );
        http_response_code(404);
    }

    $stmt->close();
    $conn->close();
} else {
    // Jika id tidak valid atau tidak ada
    $response = array(
        'status' => 'error',
        'message' => 'Invalid or missing film ID'
    );

    http_response_code(400);  // Bad Request
}

header('Content-Type: application/json');
echo json_encode($response);
