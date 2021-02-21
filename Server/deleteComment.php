<?php
require "globalFunctions.php";
$pdo = new PDO("pgsql:host=" . HOST . ";port=" . PORT . ";dbname=" . DATABASE . ";user=".USERNAME . ";password=" . PASSWORD);

$myId = $_POST["myId"];
$token = $_POST["token"];
$commentId = $_POST["commentId"];

$isValid =
    isAuthenticated($myId, $token) &&
    isExtantCommentId($commentId);
if (!$isValid) {
    $pdo = null;
    die("Invalid");
}

$query = "select count(comment_id) = 0 from comment where deleted_at is null and comment_id = ? limit 1;";
$stmt = $pdo->prepare($query);
$stmt->execute(array($commentId));

$row = $stmt->fetch();
$hasAlreadyDeleted = $row[0];

if (!$hasAlreadyDeleted) {
    $query = "update comment set deleted_at = current_timestamp where comment_id = ?;";
    $stmt = $pdo->prepare($query);
    $stmt->execute(array($commentId));

    $query = "select byte_id from comment where comment_id = ? limit 1;";
    $stmt = $pdo->prepare($query);
    $stmt->execute(array($commentId));

    $row = $stmt->fetch();
    $byteId = $row[0];
}

$return = array("hasAlreadyDeleted" => $hasAlreadyDeleted);
echo json_encode($return);

$pdo = null;
