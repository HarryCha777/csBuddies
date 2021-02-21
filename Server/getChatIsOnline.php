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

$query = "
select account.user_id,
       account.last_visited_at
from   account
       left join message
              on account.user_id = message.buddy_id
where  message.user_id = ?
group  by account.user_id;";
$stmt = $pdo->prepare($query);
$stmt->execute(array($myId));

$counter = 1; // PHP arrays start from 1
$rows = array();
while ($row = $stmt->fetch()) {
    $rows[$counter++] = array(
        "buddyId" => $row[0],
        "lastVisitedAt" => $row[1],
    );
}

echo json_encode($rows);

$pdo = null;
