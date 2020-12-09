<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $password = $_POST["password"];
  $firstChatsToday = (int)$_POST["firstChatsToday"];

	$isValid =
		isAuthenticated($myId, $password) &&
		isValidInt($firstChatsToday, 0, 50);
	if (!$isValid) {
		die("Invalid");
	}

  $query = "update account set last_first_chat_time = current_timestamp, first_chats_today = ? where user_id = ?;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($firstChatsToday, $myId));

	$pdo = null;
?>

