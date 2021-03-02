<?php
require "globalFunctions.php";
$pdo = new PDO("pgsql:host=" . HOST . ";port=" . PORT . ";dbname=" . DATABASE . ";user=".USERNAME . ";password=" . PASSWORD);

$myId = $_POST["myId"];
$token = $_POST["token"];
$userId = $_POST["userId"];
$bottomLastUpdatedAt = $_POST["bottomLastUpdatedAt"];

if (empty($myId)) {
    $myId = $emptyUuid;
}

$isValid =
    ($myId === $emptyUuid || isAuthenticated($myId, $token)) &&
    isExtantUserId($userId) &&
    isValidTime($bottomLastUpdatedAt);
if (!$isValid) {
    $pdo = null;
    die("Invalid");
}

$query = "
select byte.byte_id,
       account.user_id,
       account.username,
       account.last_visited_at,
       byte.content,
       coalesce(all_byte_like.likes, 0),
       coalesce(comment.comments, 0),
       case
         when my_byte_like.byte_like_id is null then false
         else true
       end,
       byte.posted_at,
       user_byte_like.last_updated_at
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
       left join byte_like as user_byte_like
              on user_byte_like.byte_id = byte.byte_id
                 and user_byte_like.is_liked = true
                 and user_byte_like.user_id = ?
where  byte.deleted_at is null
       and user_byte_like.last_updated_at < ?
order  by user_byte_like.last_updated_at desc
limit  20;";
$stmt = $pdo->prepare($query);
$stmt->execute(array($myId, $userId, $bottomLastUpdatedAt));

$counter = 1; // PHP arrays start from 1
$rows = array();
while ($row = $stmt->fetch()) {
    $rows[$counter++] = array(
        "byteId" => $row[0],
        "userId" => $row[1],
        "username" => $row[2],
        "lastVisitedAt" => $row[3],
        "content" => $row[4],
        "likes" => $row[5],
        "comments" => $row[6],
        "isLiked" => $row[7],
        "postedAt" => $row[8],
    );

    $bottomLastUpdatedAt = $row[9];
}

$rows[$counter++] = array(
    "bottomLastUpdatedAt" => $bottomLastUpdatedAt,
);

echo json_encode($rows);

$pdo = null;
