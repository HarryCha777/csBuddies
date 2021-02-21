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

$query = "select count(comment_id) = 1 from comment where user_id = ? and comment_id = ? limit 1;";
$stmt = $pdo->prepare($query);
$stmt->execute(array($myId, $commentId));

$row = $stmt->fetch();
$isOwnComment = $row[0];

if ($isOwnComment) {
    $pdo = null;
    die("Invalid");
}

$query = "select count(comment_like_id) = 1, is_liked from comment_like where user_id = ? and comment_id = ? group by comment_like_id limit 1;";
$stmt = $pdo->prepare($query);
$stmt->execute(array($myId, $commentId));

$row = $stmt->fetch();
$hasLikedBefore = $row[0];
$isLiked = $hasLikedBefore && $row[1];

if ($hasLikedBefore) {
    $query = "update comment_like set last_updated_at = current_timestamp, is_liked = true where user_id = ? and comment_id = ?;";
    $stmt = $pdo->prepare($query);
    $stmt->execute(array($myId, $commentId));
} else {
    $query = "insert into comment_like (user_id, comment_id) values (?, ?);";
    $stmt = $pdo->prepare($query);
    $stmt->execute(array($myId, $commentId));

    $query = "select user_id, content from comment where comment_id = ? limit 1;";
    $stmt = $pdo->prepare($query);
    $stmt->execute(array($commentId));

    $row = $stmt->fetch();
    $buddyId = $row[0];
    $content = $row[1];

    sendNotification("comment like", $myId, $buddyId, $content);
}

$return = array(
    "isLiked" => $isLiked,
);

echo json_encode($return);

$pdo = null;
