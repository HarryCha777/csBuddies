<?php
  require "globalFunctions.php";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $token = $_POST["token"];

	$isValid =
		isAuthenticated($myId, $token);
	if (!$isValid) {
  	$pdo = null;
		die("Invalid");
	}

	$query = "update account set fcm = '', last_signed_out_at = current_timestamp, disabled_at = current_timestamp where user_id = ?;";
	$stmt = $pdo->prepare($query);
	$stmt->execute(array($myId));

	$pdo = null;
?>
