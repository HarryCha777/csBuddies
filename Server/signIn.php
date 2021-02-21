<?php
require "globalFunctions.php";
$pdo = new PDO("pgsql:host=" . HOST . ";port=" . PORT . ";dbname=" . DATABASE . ";user=".USERNAME . ";password=" . PASSWORD);

$myId = $_POST["myId"];
$token = $_POST["token"];
$fcm = $_POST["fcm"];

$isValid =
    isAuthenticated($myId, $token, $mustBeActive = false) &&
    isValidString($fcm, 0, 1000);
if (!$isValid) {
    $pdo = null;
    die("Invalid");
}

$query = "update account set fcm = ?, last_signed_in_at = current_timestamp, disabled_at = null where user_id = ?;";
$stmt = $pdo->prepare($query);
$stmt->execute(array($fcm, $myId));

$pdo = null;
