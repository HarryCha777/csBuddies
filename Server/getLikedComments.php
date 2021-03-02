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
 select comment.comment_id,
       comment.byte_id,
       account.user_id,
       account.username,
       account.last_visited_at,
       coalesce(parent_account.user_id, '{$emptyUuid}'),
       coalesce(parent_account.username, ''),
       comment.content,
       coalesce(all_comment_like.likes, 0),
       case
         when my_comment_like.comment_like_id is null then false
         else true
       end,
       comment.posted_at,
       user_comment_like.last_updated_at
from   comment
       left join account
              on account.user_id = comment.user_id
       left join (select comment_id,
                         count(comment_like_id) as likes
                  from   comment_like
                  where  is_liked = true
                  group  by comment_id) as all_comment_like
              on all_comment_like.comment_id = comment.comment_id
       left join comment_like as my_comment_like
              on my_comment_like.comment_id = comment.comment_id
                 and my_comment_like.is_liked = true
                 and my_comment_like.user_id = ?
       left join comment_like as user_comment_like
              on user_comment_like.comment_id = comment.comment_id
                 and user_comment_like.is_liked = true
                 and user_comment_like.user_id = ?
       left join comment as parent_comment
              on parent_comment.comment_id = comment.parent_comment_id
       left join account as parent_account
              on parent_account.user_id = parent_comment.user_id
where  comment.deleted_at is null
       and user_comment_like.last_updated_at < ?
order  by user_comment_like.last_updated_at desc
limit  20;";
$stmt = $pdo->prepare($query);
$stmt->execute(array($myId, $userId, $bottomLastUpdatedAt));

$counter = 1; // PHP arrays start from 1
$rows = array();
while ($row = $stmt->fetch()) {
    $rows[$counter++] = array(
        "commentId" => $row[0],
        "byteId" => $row[1],
        "userId" => $row[2],
        "username" => $row[3],
        "lastVisitedAt" => $row[4],
        "parentUserId" => $row[5],
        "parentUsername" => $row[6],
        "content" => $row[7],
        "likes" => $row[8],
        "isLiked" => $row[9],
        "postedAt" => $row[10],
    );

    $bottomLastUpdatedAt = $row[11];
}

$rows[$counter++] = array(
    "bottomLastUpdatedAt" => $bottomLastUpdatedAt,
);

echo json_encode($rows);

$pdo = null;
