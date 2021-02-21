<?php
require "globalFunctions.php";
$pdo = new PDO("pgsql:host=" . HOST . ";port=" . PORT . ";dbname=" . DATABASE . ";user=" . USERNAME . ";password=" . PASSWORD);

$buddyId = $_POST["buddyId"];

$isValid =
    isExtantUserId($buddyId);
if (!$isValid) {
    $pdo = null;
    die("Invalid");
}

$query = "select username, banned_at is not null, deleted_at from account where user_id = ? limit 1;";
$stmt = $pdo->prepare($query);
$stmt->execute(array($buddyId));

$row = $stmt->fetch();
$username = $row[0];
$isBanned = $row[1];
$isDeleted = $row[2];

if ($isBanned) {
    $return = array(
        "username" => $username,
        "isBanned" => true,
    );
    echo json_encode($return);
    $pdo = null;
    exit;
}

if ($isDeleted) {
    $return = array(
        "username" => $username,
        "isDeleted" => true,
    );
    echo json_encode($return);
    $pdo = null;
    exit;
}

$query = "select count(byte_id) from byte where deleted_at is null and user_id = ? limit 1;";
$stmt = $pdo->prepare($query);
$stmt->execute(array($buddyId));

$row = $stmt->fetch();
$bytesMade = $row[0];

$query = "select count(comment_id) from comment where deleted_at is null and user_id = ? limit 1;";
$stmt = $pdo->prepare($query);
$stmt->execute(array($buddyId));

$row = $stmt->fetch();
$commentsMade = $row[0];

$query = "
select count(byte.user_id)
from   byte
       left join byte_like
              on byte.byte_id = byte_like.byte_id
where  byte.byte_id = byte_like.byte_id
       and byte_like.is_liked = true
       and byte.user_id = ?
limit  1;";
$stmt = $pdo->prepare($query);
$stmt->execute(array($buddyId));

$row = $stmt->fetch();
$byteLikesReceived = $row[0];

$query = "
select count(comment.user_id)
from   comment
       left join comment_like
              on comment.comment_id = comment_like.comment_id
where  comment.comment_id = comment_like.comment_id
       and comment_like.is_liked = true
       and comment.user_id = ?
limit  1;";
$stmt = $pdo->prepare($query);
$stmt->execute(array($buddyId));

$row = $stmt->fetch();
$commentLikesReceived = $row[0];

$query = "select count(user_id) from byte_like where is_liked = true and user_id = ? limit 1;";
$stmt = $pdo->prepare($query);
$stmt->execute(array($buddyId));

$row = $stmt->fetch();
$byteLikesGiven = $row[0];

$query = "select count(user_id) from comment_like where is_liked = true and user_id = ? limit 1;";
$stmt = $pdo->prepare($query);
$stmt->execute(array($buddyId));

$row = $stmt->fetch();
$commentLikesGiven = $row[0];

$query = "select username, gender, birthday, country, interests, intro, github, linkedin, last_visited_at, last_updated_at, became_admin_at is not null from account where user_id = ? limit 1;";
$stmt = $pdo->prepare($query);
$stmt->execute(array($buddyId));

$row = $stmt->fetch();

$return = array(
    "username" => $row[0],
    "gender" => $row[1],
    "birthday" => $row[2],
    "country" => $row[3],
    "interests" => $row[4],
    "intro" => $row[5],
    "github" => $row[6],
    "linkedin" => $row[7],
    "lastVisitedAt" => $row[8],
    "lastUpdatedAt" => $row[9],
    "isAdmin" => $row[10],
    "bytesMade" => $bytesMade,
    "commentsMade" => $commentsMade,
    "byteLikesReceived" => $byteLikesReceived,
    "commentLikesReceived" => $commentLikesReceived,
    "byteLikesGiven" => $byteLikesGiven,
    "commentLikesGiven" => $commentLikesGiven,
);
echo json_encode($return);

$pdo = null;
