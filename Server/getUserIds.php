<?php
require "globalFunctions.php";
$pdo = new PDO("pgsql:host=" . HOST . ";port=" . PORT . ";dbname=" . DATABASE . ";user=".USERNAME . ";password=" . PASSWORD);

die("Invalid");

$query = "select user_id from account;";
$stmt = $pdo->prepare($query);
$stmt->execute(array());

$counter = 1; // PHP arrays start from 1
$rows = array();
while ($row = $stmt->fetch()) {
    $rows[$counter++] = array(
        "userId" => $row[0],
    );
}

echo json_encode($rows);

$pdo = null;
