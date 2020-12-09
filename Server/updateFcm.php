<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $password = $_POST["password"];
  $fcm = $_POST["fcm"];

	$isValid =
		isAuthenticated($myId, $password) &&
		isValidString($fcm, 0, 1000);
	if (!$isValid) {
		die("Invalid");
	}

  $query = "update account set fcm = ? where user_id = ?;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($fcm, $myId));

	$pdo = null;
?>

