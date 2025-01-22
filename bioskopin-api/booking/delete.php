<?php
require '../config/database.php';
$db = new Database();
$conn = $db->getConnection();

// Mengecek apakah parameter 'id' ada
if (!empty($_GET['id'])) {
    $id = $_GET['id'];

    // Menyiapkan query SQL menggunakan prepared statement
    $query = "DELETE FROM booking WHERE id = ?";

    if ($stmt = $conn->prepare($query)) {
        // Mengikat parameter ID ke prepared statement
        $stmt->bind_param("i", $id); // "i" artinya tipe data integer

        // Menjalankan query
        if ($stmt->execute()) {
            $response = array(
                'status' => 'success',
                'message' => 'Pemesanan berhasil dihapus'
            );

            // Mengirimkan response
            header('Content-Type: application/json');
            http_response_code(200);
            echo json_encode($response);
        } else {
            // Jika eksekusi gagal
            $response = array(
                'status' => 'error',
                'message' => 'Gagal menghapus pemesanan'
            );
            header('Content-Type: application/json');
            http_response_code(500);
            echo json_encode($response);
        }

        // Menutup prepared statement
        $stmt->close();
    } else {
        // Jika gagal menyiapkan query
        $response = array(
            'status' => 'error',
            'message' => 'Terjadi kesalahan pada query database'
        );
        header('Content-Type: application/json');
        http_response_code(500);
        echo json_encode($response);
    }
} else {
    // Jika parameter 'id' tidak ada
    $response = array(
        'status' => 'error',
        'message' => 'Data tidak lengkap: ID diperlukan'
    );
    header('Content-Type: application/json');
    http_response_code(400);
    echo json_encode($response);
}
