<?php
require "globalFunctions.php";
$pdo = new PDO("pgsql:host=" . HOST . ";port=" . PORT . ";dbname=" . DATABASE . ";user=".USERNAME . ";password=" . PASSWORD);

$myId = $_POST["myId"];
$token = $_POST["token"];
$byteId = $_POST["byteId"];

if (empty($myId)) {
    $myId = $emptyUuid;
}

$isValid =
    ($myId === $emptyUuid || isAuthenticated($myId, $token)) &&
    isExtantByteId($byteId);
if (!$isValid) {
    $pdo = null;
    die("Invalid");
}

$query = "select deleted_at is not null from byte where byte_id = ? limit 1;";
$stmt = $pdo->prepare($query);
$stmt->execute(array($byteId));

$row = $stmt->fetch();
$isDeleted = $row[0];

if ($isDeleted) {
    $return = array("isDeleted" => true);
    echo json_encode($return);
    $pdo = null;
    exit;
}

$query = "
select account.user_id,
       account.username,
       account.last_visited_at,
       byte.content,
       coalesce(all_byte_like.likes, 0),
       coalesce(comment.comments, 0),
       case
         when my_byte_like.byte_like_id is null then false
         else true
       end,
       byte.posted_at
from   byte
       left join account
              on account.user_id = byte.user_id
       left join (select byte_id,
                         count(comment_id) as comments
                  from   comment
                  where  deleted_at is null
                  group  by byte_id) as comment
              on comment.byte_id = byte.byte_id
       left join (select byte_id,
                         count(byte_like_id) as likes
                  from   byte_like
                  where  is_liked = true
                  group  by byte_id) as all_byte_like
              on all_byte_like.byte_id = byte.byte_id
       left join byte_like as my_byte_like
              on my_byte_like.byte_id = byte.byte_id
                 and my_byte_like.is_liked = true
                 and my_byte_like.user_id = ?
where  byte.byte_id = ?;";
$stmt = $pdo->prepare($query);
$stmt->execute(array($myId, $byteId));

$row = $stmt->fetch();

$return = array(
    "userId" => $row[0],
    "username" => $row[1],
    "lastVisitedAt" => $row[2],
    "content" => $row[3],
    "likes" => $row[4],
    "comments" => $row[5],
    "isLiked" => $row[6],
    "postedAt" => $row[7],
);
echo json_encode($return);

$pdo = null;
