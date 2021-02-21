<?php
use Kreait\Firebase\Factory;

die("Invalid");

require "globalFunctions.php";
$pdo = new PDO("pgsql:host=" . HOST . ";port=" . PORT . ";dbname=" . DATABASE . ";user=".USERNAME . ";password=" . PASSWORD);

require "/var/www/inc/vendor/autoload.php";

$factory = (new Factory)->withServiceAccount("/var/www/inc/firebaseAdminSdk.json");
$auth = $factory->createAuth();

/*//$myId = "26aeba88-4eb6-4b0b-9ed3-572f39fe50c5";
$myId = "dummy data";
$uid = "R6OTqy79LBNyVN823oFLyXn3k0Y2";
$auth->setCustomUserClaims($uid, ["userId" => $myId]);*/

$query = "select email, user_id from account;";
$stmt = $pdo->prepare($query);
$stmt->execute();

while ($row = $stmt->fetch()) {
    $email = $row[0];
    $userId = $row[1];
    $user = $auth->getUserByEmail($email);
    $uid = $user->uid;
    $auth->setCustomUserClaims($uid, ["userId" => $userId]);
}

$pdo = null;
