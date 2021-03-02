<?php
require "globalFunctions.php";
$pdo = new PDO("pgsql:host=" . HOST . ";port=" . PORT . ";dbname=" . DATABASE . ";user=" . USERNAME . ";password=" . PASSWORD);

$myId = $_POST["myId"];
$token = $_POST["token"];
$byteId = $_POST["byteId"];
$bottomPostedAt = $_POST["bottomPostedAt"];

if (empty($myId)) {
    $myId = $emptyUuid;
}

$isValid =
    ($myId === $emptyUuid || isAuthenticated($myId, $token)) &&
    isExtantByteId($byteId) &&
    isValidTime($bottomPostedAt);
if (!$isValid) {
    $pdo = null;
    die("Invalid");
}

$query = "
select comment.comment_id,
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
       comment.posted_at
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
       left join comment as parent_comment
              on parent_comment.comment_id = comment.parent_comment_id
       left join account as parent_account
              on parent_account.user_id = parent_comment.user_id
where  ( account.banned_at is null
          or account.user_id = ? )
       and comment.deleted_at is null
       and comment.byte_id = ?
       and comment.posted_at > ?
order  by comment.posted_at asc
limit  20;";
$stmt = $pdo->prepare($query);
$stmt->execute(array($myId, $myId, $byteId, $bottomPostedAt));

$counter = 1; // PHP arrays start from 1
$rows = array();
while ($row = $stmt->fetch()) {
    $rows[$counter++] = array(
        "commentId" => $row[0],
        "userId" => $row[1],
        "username" => $row[2],
        "lastVisitedAt" => $row[3],
        "parentUserId" => $row[4],
        "parentUsername" => $row[5],
        "content" => $row[6],
        "likes" => $row[7],
        "isLiked" => $row[8],
        "postedAt" => $row[9],
    );

    $bottomPostedAt = $row[9];
}

$rows[$counter++] = array(
    "bottomPostedAt" => $bottomPostedAt,
);

echo json_encode($rows);

$pdo = null;
