<?php
require "globalFunctions.php";
$pdo = new PDO("pgsql:host=" . HOST . ";port=" . PORT . ";dbname=" . DATABASE . ";user=".USERNAME . ";password=" . PASSWORD);

$myId = $_POST["myId"];
$token = $_POST["token"];
$byteId = $_POST["byteId"];

$isValid =
    isAuthenticated($myId, $token) &&
    isExtantByteId($byteId);
if (!$isValid) {
    $pdo = null;
    die("Invalid");
}

$query = "select count(byte_id) = 1 from byte where user_id = ? and byte_id = ? limit 1;";
$stmt = $pdo->prepare($query);
$stmt->execute(array($myId, $byteId));

$row = $stmt->fetch();
$isOwnByte = $row[0];

if ($isOwnByte) {
    $pdo = null;
    die("Invalid");
}

$query = "select count(byte_like_id) = 1, is_liked from byte_like where user_id = ? and byte_id = ? group by byte_like_id limit 1;";
$stmt = $pdo->prepare($query);
$stmt->execute(array($myId, $byteId));

$row = $stmt->fetch();
$hasLikedBefore = $row[0];
$isLiked = $hasLikedBefore && $row[1];

if ($hasLikedBefore) {
    $query = "update byte_like set last_updated_at = current_timestamp, is_liked = true where user_id = ? and byte_id = ?;";
    $stmt = $pdo->prepare($query);
    $stmt->execute(array($myId, $byteId));
} else {
    $query = "insert into byte_like (user_id, byte_id) values (?, ?);";
    $stmt = $pdo->prepare($query);
    $stmt->execute(array($myId, $byteId));

    $query = "select user_id, content from byte where byte_id = ? limit 1;";
    $stmt = $pdo->prepare($query);
    $stmt->execute(array($byteId));

    $row = $stmt->fetch();
    $buddyId = $row[0];
    $content = $row[1];

    sendNotification("byte like", $myId, $buddyId, $content);
}

$return = array(
    "isLiked" => $isLiked,
);

echo json_encode($return);

$pdo = null;
