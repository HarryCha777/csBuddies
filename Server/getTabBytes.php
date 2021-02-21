<?php
require "globalFunctions.php";
$pdo = new PDO("pgsql:host=" . HOST . ";port=" . PORT . ";dbname=" . DATABASE . ";user=".USERNAME . ";password=" . PASSWORD);

$myId = $_POST["myId"];
$token = $_POST["token"];
$sort = $_POST["sort"]; // 0 = hot, 1 = new
$bottomPostedAt = $_POST["bottomPostedAt"];
$bottomHotScore = $_POST["bottomHotScore"];

if (empty($myId)) {
    $myId = $emptyUuid;
}

$isValid =
    ($myId === $emptyUuid || isAuthenticated($myId, $token)) &&
    isValidInt($sort, 0, 1) &&
    isValidTime($bottomPostedAt) &&
    isValidInt($bottomHotScore, 0, 30000);
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
       byte.posted_at
from   byte
       left join account
              on byte.user_id = account.user_id
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
where  ( account.banned_at is null
          or account.user_id = ? )
       and byte.deleted_at is null ";
$paramsArray = array($myId, $myId);

if ($sort === 0) {
    # 1606780800 is unix timestamp for 2020-12-01, and 86400 is number of seconds in a day.
    $hotScoreSql = "round(cast(greatest(log(10, greatest(all_byte_like.likes, 1)), 1) + (extract(epoch from byte.posted_at) - 1606780800) / 86400 as numeric), 3)";
    $query .= "
           and (({$hotScoreSql} = ? and byte.posted_at < ?) or ({$hotScoreSql} < ?))
    order  by {$hotScoreSql} desc, byte.posted_at desc
    limit  20;";
    array_push($paramsArray, $bottomHotScore, $bottomPostedAt, $bottomHotScore);
} else {
    $query .= "
           and byte.posted_at < ?
    order  by byte.posted_at desc
    limit  20;";
    array_push($paramsArray, $bottomPostedAt);
}

$stmt = $pdo->prepare($query);
$stmt->execute($paramsArray);

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

    $bottomPostedAt = $row[8];
    # 1606780800 is unix timestamp for 2020-12-01, and 86400 is number of seconds in a day.
    $hotScorePhp = round(max(log10($row[5]), 1) + (strtotime($row[8]) - 1606780800) / 86400, 3);
    $bottomHotScore = $hotScorePhp;
}

$rows[$counter++] = array(
    "bottomPostedAt" => $bottomPostedAt,
    "bottomHotScore" => $bottomHotScore,
);

echo json_encode($rows);

$pdo = null;
