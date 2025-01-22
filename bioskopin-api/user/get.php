<?php
require_once '../config/database.php';

$db = new Database();
$conn = $db->getConnection();
$query = "SELECT id, fullname, email FROM users WHERE role = 'user' ORDER BY created_at DESC";
$stmt = $conn->prepare($query);
$stmt->execute();
$result = $stmt->get_result();
$users = [];

while ($row = $result->fetch_assoc()) {
    $users[] = $row;
}

$response = array(
    'status' => 'success',
    'data' => $users
);

$stmt->close();
$conn->close();

header('Content-Type: application/json');
echo json_encode($response);
