<?php
require "globalFunctions.php";
$pdo = new PDO("pgsql:host=" . HOST . ";port=" . PORT . ";dbname=" . DATABASE . ";user=".USERNAME . ";password=" . PASSWORD);

$myId = $_POST["myId"];
$token = $_POST["token"];
$badges = $_POST["badges"];

$isValid =
    isAuthenticated($myId, $token) &&
    isValidInt($badges, 0, 30000);
if (!$isValid) {
    $pdo = null;
    die("Invalid");
}

$query = "update account set badges = ? where user_id = ?;";
$stmt = $pdo->prepare($query);
$stmt->execute(array($badges, $myId));

$pdo = null;
