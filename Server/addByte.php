<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
	$pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $password = $_POST["password"];
  $content = $_POST["content"];

	$isValid =
		isAuthenticated($myId, $password) &&
		isValidString($content, 1, 256);
	if (!$isValid) {
		die("Invalid");
	}

  $query = "insert into byte (user_id, content, likes, post_time, is_deleted) values (?, ?, 0, current_timestamp, false);";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId, $content));

  $pdo = null;
?>

