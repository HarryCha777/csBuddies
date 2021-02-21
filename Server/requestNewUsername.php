<?php
require "globalFunctions.php";
$pdo = new PDO("pgsql:host=" . HOST . ";port=" . PORT . ";dbname=" . DATABASE . ";user=".USERNAME . ";password=" . PASSWORD);

$myId = $_POST["myId"];
$token = $_POST["token"];
$newUsername = $_POST["newUsername"];
$reason = $_POST["reason"];
$comments = $_POST["comments"];
$mustReplacePrevious = $_POST["mustReplacePrevious"];

$isValid =
    isAuthenticated($myId, $token) &&
    isValidUsername($newUsername) &&
    isValidInt($reason, 0, 2) &&
    isValidString($comments, 0, 1000) &&
    isValidBool($mustReplacePrevious);
if (!$isValid) {
    $pdo = null;
    die("Invalid");
}

if (isExtantUsername($emptyUuid, $newUsername)) {
    $return = array("isExtantUsername" => true);
    echo json_encode($return);
    $pdo = null;
    exit;
}

if (!toBool($mustReplacePrevious)) {
    $query = "select count(username_change_request_id) = 1 from username_change_request where user_id = ? and reviewed_at is null limit 1;";
    $stmt = $pdo->prepare($query);
    $stmt->execute(array($myId));

    $row = $stmt->fetch();
    $isExtantRequest = $row[0];

    if ($isExtantRequest) {
        $return = array("isExtantRequest" => true);
        echo json_encode($return);
        $pdo = null;
        exit;
    }
}

if (toBool($mustReplacePrevious)) {
    $query = "delete from username_change_request where user_id = ? and reviewed_at is null;";
    $stmt = $pdo->prepare($query);
    $stmt->execute(array($myId));
}

$query = "select username from account where user_id = ? limit 1;";
$stmt = $pdo->prepare($query);
$stmt->execute(array($myId));

$row = $stmt->fetch();
$username = $row[0];

$query = "insert into username_change_request (user_id, username, new_username, reason, comments) values (?, ?, ?, ?, ?);";
$stmt = $pdo->prepare($query);
$stmt->execute(array($myId, $username, $newUsername, $reason, $comments));

$pdo = null;
