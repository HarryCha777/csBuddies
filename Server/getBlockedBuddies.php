<?php
require "globalFunctions.php";
$pdo = new PDO("pgsql:host=" . HOST . ";port=" . PORT . ";dbname=" . DATABASE . ";user=".USERNAME . ";password=" . PASSWORD);

$myId = $_POST["myId"];
$token = $_POST["token"];
$bottomBlockedAt = $_POST["bottomBlockedAt"];

$isValid =
    isAuthenticated($myId, $token) &&
    isValidTime($bottomBlockedAt);
if (!$isValid) {
    $pdo = null;
    die("Invalid");
}

$query = "
select account.user_id,
       account.username,
       account.birthday,
       account.gender,
       account.country,
       account.intro,
       account.last_visited_at,
       block.blocked_at
from   block
       left join account
              on block.buddy_id = account.user_id
where  account.deleted_at is null
       and block.user_id = ?
       and block.blocked_at < ?
order  by block.blocked_at desc
limit  20;";
$stmt = $pdo->prepare($query);
$stmt->execute(array($myId, $bottomBlockedAt));

$counter = 1; // PHP arrays start from 1
$return = array();
while ($row = $stmt->fetch()) {
    $return[$counter++] = array(
        "buddyId" => $row[0],
        "username" => $row[1],
        "birthday" => $row[2],
        "gender" => $row[3],
        "country" => $row[4],
        "intro" => $row[5],
        "lastVisitedAt" => $row[6],
    );

    $bottomBlockedAt = $row[7];
}

$return[$counter++] = array(
    "bottomBlockedAt" => $bottomBlockedAt,
);

echo json_encode($return);

$pdo = null;
