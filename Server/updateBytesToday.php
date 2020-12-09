<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $password = $_POST["password"];
  $bytesToday = (int)$_POST["bytesToday"];

	$isValid =
		isAuthenticated($myId, $password) &&
		isValidInt($bytesToday, 0, 50);
	if (!$isValid) {
		die("Invalid");
	}

  $query = "update account set last_post_time = current_timestamp, bytes_today = ? where user_id = ?;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($bytesToday, $myId));

	$pdo = null;
?>

