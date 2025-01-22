<?php
require_once '../config/database.php';

// Jika token valid, lanjutkan untuk mengambil data booking
$db = new Database();
$conn = $db->getConnection();

// Mengecek apakah ada parameter 'user_id' pada query string
$userId = isset($_GET['user_id']) ? $_GET['user_id'] : null;

if ($userId) {
    // Jika 'user_id' ada, ambil data booking untuk user tertentu
    $query = "SELECT booking.id, film.title, booking.ticket_quantity, booking.total_price, booking.status, booking.created_at 
              FROM booking 
              JOIN film ON booking.film_id = film.id 
              JOIN users ON booking.user_id = users.id 
              WHERE booking.user_id = ? 
              ORDER BY created_at DESC";
} else {
    // Jika 'user_id' tidak ada, ambil semua data booking
    $query = "SELECT booking.id, film.title, booking.ticket_quantity, booking.total_price, booking.status, booking.created_at 
              FROM booking 
              JOIN film ON booking.film_id = film.id 
              JOIN users ON booking.user_id = users.id 
              ORDER BY created_at DESC";
}

// Menyiapkan query dengan prepared statement
if ($stmt = $conn->prepare($query)) {
    if ($userId) {
        // Mengikat parameter 'user_id' jika ada
        $stmt->bind_param("i", $userId); // "i" berarti integer
    }

    // Menjalankan query
    $stmt->execute();

    // Mengambil hasil
    $result = $stmt->get_result();
    $bookings = [];

    // Mengambil data booking dalam bentuk array
    while ($row = $result->fetch_assoc()) {
        $bookings[] = $row;
    }

    // Mengirimkan data booking dalam format JSON
    $response = array(
        'status' => 'success',
        'data' => $bookings
    );

    header('Content-Type: application/json');
    http_response_code(200);
    echo json_encode($response);

    // Menutup statement
    $stmt->close();
} else {
    // Jika query gagal menyiapkan
    $response = array(
        'status' => 'error',
        'message' => 'Terjadi kesalahan pada query database'
    );

    header('Content-Type: application/json');
    http_response_code(500);
    echo json_encode($response);
}
