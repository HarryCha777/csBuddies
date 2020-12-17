<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $password = $_POST["password"];
  $hasByteNotification = $_POST["hasByteNotification"];
  $hasChatNotification = $_POST["hasChatNotification"];

	$isValid =
		isAuthenticated($myId, $password) &&
		isValidBool($hasByteNotification) &&
		isValidBool($hasChatNotification);
	if (!$isValid) {
  	$pdo = null;
		die("Invalid");
	}

  $query = "update account set has_byte_notification = ?, has_chat_notification = ? where user_id = ?;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($hasByteNotification, $hasChatNotification, $myId));

	$pdo = null;
?>

