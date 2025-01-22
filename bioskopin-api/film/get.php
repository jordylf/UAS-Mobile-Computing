<?php
require_once '../config/database.php';

$db = new Database();
$conn = $db->getConnection();
$query = "SELECT id, title, price, image, description FROM film ORDER BY created_at DESC";
$stmt = $conn->prepare($query);
$stmt->execute();
$result = $stmt->get_result();
$movies = [];

$protocol = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? 'https' : 'http';
$host = $_SERVER['HTTP_HOST'];
$baseUrl = "$protocol://$host/bioskopin-api/uploads/";

while ($row = $result->fetch_assoc()) {
    $row['image'] = $baseUrl . htmlspecialchars($row['image']);
    $row['title'] = htmlspecialchars($row['title']);
    $row['description'] = htmlspecialchars($row['description']);
    $movies[] = $row;
}

$response = array(
    'status' => 'success',
    'data' => $movies
);

$stmt->close();
$conn->close();

header('Content-Type: application/json');
echo json_encode($response);
