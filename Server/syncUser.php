<?php
require "globalFunctions.php";
$pdo = new PDO("pgsql:host=" . HOST . ";port=" . PORT . ";dbname=" . DATABASE . ";user=".USERNAME . ";password=" . PASSWORD);

$myId = $_POST["myId"];
$token = $_POST["token"];

$isValid =
    isAuthenticated($myId, $token);
if (!$isValid) {
    $pdo = null;
    die("Invalid");
}

$query = "select last_synced_at, became_premium_at is not null, became_admin_at is not null, user_outdated_at is not null, banned_at is not null from account where user_id = ? limit 1;";
$stmt = $pdo->prepare($query);
$stmt->execute(array($myId));

$row = $stmt->fetch();
$lastSyncedAt = $row[0];
$isPremium = $row[1];
$isAdmin = $row[2];
$isUserOutdated = $row[3];
$isBanned = $row[4];

$query = "
select count(byte_like.byte_like_id)
from   byte_like
       left join byte
              on byte.byte_id = byte_like.byte_id
       left join account
              on account.user_id = byte.user_id
where  account.user_id = ?
       and byte_like.is_liked = true
limit  1;";
$stmt = $pdo->prepare($query);
$stmt->execute(array($myId));

$row = $stmt->fetch();
$byteLikesReceived = $row[0];

$query = "
select count(comment_like.comment_like_id)
from   comment_like
       left join comment
              on comment.comment_id = comment_like.comment_id
       left join account
              on account.user_id = comment.user_id
where  account.user_id = ?
       and comment_like.is_liked = true
limit  1;";
$stmt = $pdo->prepare($query);
$stmt->execute(array($myId));

$row = $stmt->fetch();
$commentLikesReceived = $row[0];

$query = "update account set last_synced_at = current_timestamp where user_id = ?;";
$stmt = $pdo->prepare($query);
$stmt->execute(array($myId));

if ($isBanned) {
    $return = array(
        "isPremium" => $isPremium,
        "isAdmin" => $isAdmin,
        "isUserOutdated" => $isUserOutdated,
        "byteLikesReceived" => $byteLikesReceived,
        "commentLikesReceived" => $commentLikesReceived,
        "byteLikes" => $byteLikes,
        "commentLikes" => $commentLikes,
        "comments" => $comments,
        "replies" => $replies,
        "messages" => $messages,
        "myMessages" => $myMessages,
        "readReceipts" => $readReceipts,
    );
    echo json_encode($return);

    $pdo = null;
    exit;
}

$query = "
select byte_like.byte_like_id,
       byte.byte_id,
       account.user_id,
       account.username,
       account.last_visited_at,
       byte.content,
       byte_like.last_updated_at
from   byte_like
       left join byte
              on byte_like.byte_id = byte.byte_id
       left join account
              on byte_like.user_id = account.user_id
       left join block
              on block.user_id = byte.user_id
where  byte.user_id = ?
       and not byte.user_id = byte_like.user_id
       and not coalesce(block.buddy_id, '{$emptyUuid}') = account.user_id
       and account.banned_at is null
       and byte_like.is_liked = true
       and byte_like.last_updated_at > ?;";
$stmt = $pdo->prepare($query);
$stmt->execute(array($myId, $lastSyncedAt));

$counter = 1; // PHP arrays start from 1
$byteLikes = array();
while ($row = $stmt->fetch()) {
    $byteLikes[$counter++] = array(
        "notificationId" => $row[0],
        "byteId" => $row[1],
        "buddyId" => $row[2],
        "buddyUsername" => $row[3],
        "lastVisitedAt" => $row[4],
        "content" => $row[5],
        "notifiedAt" => $row[6],
    );
}

$query = "
select comment_like.comment_like_id,
       comment.byte_id,
       account.user_id,
       account.username,
       account.last_visited_at,
       comment.content,
       comment_like.last_updated_at
from   comment_like
       left join comment
              on comment_like.comment_id = comment.comment_id
       left join account
              on comment_like.user_id = account.user_id
       left join block
              on block.user_id = comment.user_id
where  comment.user_id = ?
       and not comment.user_id = comment_like.user_id
       and not coalesce(block.buddy_id, '{$emptyUuid}') = account.user_id
       and account.banned_at is null
       and comment_like.is_liked = true
       and comment_like.last_updated_at > ?;";
$stmt = $pdo->prepare($query);
$stmt->execute(array($myId, $lastSyncedAt));

$counter = 1; // PHP arrays start from 1
$commentLikes = array();
while ($row = $stmt->fetch()) {
    $commentLikes[$counter++] = array(
        "notificationId" => $row[0],
        "byteId" => $row[1],
        "buddyId" => $row[2],
        "buddyUsername" => $row[3],
        "lastVisitedAt" => $row[4],
        "content" => $row[5],
        "notifiedAt" => $row[6],
    );
}

$query = "
select comment.comment_id,
       byte.byte_id,
       account.user_id,
       account.username,
       account.last_visited_at,
       comment.content,
       comment.posted_at
from   byte
       left join comment
              on comment.byte_id = byte.byte_id
       left join account
              on account.user_id = comment.user_id
       left join block
              on block.user_id = byte.user_id
where  byte.user_id = ?
       and not byte.user_id = comment.user_id
       and not coalesce(block.buddy_id, '{$emptyUuid}') = account.user_id
       and account.banned_at is null
       and comment.parent_comment_id = '{$emptyUuid}'
       and comment.deleted_at is null
       and comment.posted_at > ?;";
$stmt = $pdo->prepare($query);
$stmt->execute(array($myId, $lastSyncedAt));

$counter = 1; // PHP arrays start from 1
$comments = array();
while ($row = $stmt->fetch()) {
    $comments[$counter++] = array(
        "notificationId" => $row[0],
        "byteId" => $row[1],
        "buddyId" => $row[2],
        "buddyUsername" => $row[3],
        "lastVisitedAt" => $row[4],
        "content" => $row[5],
        "notifiedAt" => $row[6],
    );
}

// Remember to use "!=" in SQL instead of "!==" like in PHP.
$query = "
select comment.comment_id,
       comment.byte_id,
       account.user_id,
       account.username,
       account.last_visited_at,
       comment.content,
       comment.posted_at
from   comment
       left join account
              on account.user_id = comment.user_id
       left join comment as parent_comment
              on parent_comment.comment_id = comment.parent_comment_id
       left join block
              on block.user_id = parent_comment.user_id
where  parent_comment.user_id = ?
       and not comment.user_id = parent_comment.user_id
       and not coalesce(block.buddy_id, '{$emptyUuid}') = account.user_id
       and account.banned_at is null
       and comment.parent_comment_id != '{$emptyUuid}'
       and comment.deleted_at is null
       and comment.posted_at > ?;";
$stmt = $pdo->prepare($query);
$stmt->execute(array($myId, $lastSyncedAt));

$counter = 1; // PHP arrays start from 1
$replies = array();
while ($row = $stmt->fetch()) {
    $replies[$counter++] = array(
        "notificationId" => $row[0],
        "byteId" => $row[1],
        "buddyId" => $row[2],
        "buddyUsername" => $row[3],
        "lastVisitedAt" => $row[4],
        "content" => $row[5],
        "notifiedAt" => $row[6],
    );
}

$query = "
 select message.message_id,
       account.user_id,
       account.username,
       message.content,
       message.sent_at
from   message
       left join account
              on account.user_id = message.user_id
       left join block
              on block.user_id = message.buddy_id
where  message.buddy_id = ?
       and not coalesce(block.buddy_id, '{$emptyUuid}') = account.user_id
       and account.banned_at is null
       and message.sent_at > ?;";
$stmt = $pdo->prepare($query);
$stmt->execute(array($myId, $lastSyncedAt));

$counter = 1; // PHP arrays start from 1
$messages = array();
while ($row = $stmt->fetch()) {
    $messages[$counter++] = array(
        "messageId" => $row[0],
        "buddyId" => $row[1],
        "buddyUsername" => $row[2],
        "content" => $row[3],
        "sentAt" => $row[4],
    );
}

// myMessages is unnecessary unless deleted chat history must be restored by setting lastSyncedAt to the past.
if (substr($lastSyncedAt, 0, 10) === "2000-01-01") {
    $query = "
    select message.message_id,
           account.user_id,
           account.username,
           message.content,
           message.sent_at
    from   message
           left join account
                  on account.user_id = message.buddy_id
    where  message.user_id = ?
           and message.sent_at > ?;";
    $stmt = $pdo->prepare($query);
    $stmt->execute(array($myId, $lastSyncedAt));

    $counter = 1; // PHP arrays start from 1
    $myMessages = array();
    while ($row = $stmt->fetch()) {
        $myMessages[$counter++] = array(
            "messageId" => $row[0],
            "buddyId" => $row[1],
            "buddyUsername" => $row[2],
            "content" => $row[3],
            "sentAt" => $row[4],
        );
    }
}

$query = "select user_id, last_read_at from read_receipt where buddy_id = ? and last_read_at > ?;";
$stmt = $pdo->prepare($query);
$stmt->execute(array($myId, $lastSyncedAt));

$counter = 1; // PHP arrays start from 1
$readReceipts = array();
while ($row = $stmt->fetch()) {
    $readReceipts[$counter++] = array(
        "buddyId" => $row[0],
        "lastReadAt" => $row[1],
    );
}

$return = array(
    "isPremium" => $isPremium,
    "isAdmin" => $isAdmin,
    "isUserOutdated" => $isUserOutdated,
    "byteLikesReceived" => $byteLikesReceived,
    "commentLikesReceived" => $commentLikesReceived,
    "byteLikes" => $byteLikes,
    "commentLikes" => $commentLikes,
    "comments" => $comments,
    "replies" => $replies,
    "messages" => $messages,
    "myMessages" => $myMessages,
    "readReceipts" => $readReceipts,
);
echo json_encode($return);

$pdo = null;
