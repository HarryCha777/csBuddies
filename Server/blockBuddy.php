<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $password = $_POST["password"];
  $buddyId = $_POST["buddyId"];

	$isValid =
		isAuthenticated($myId, $password) &&
		isExtantUserId($buddyId);
	if (!$isValid) {
		die("Invalid");
	}

  $query = "select count(block_Id) from block where user_id = ? and buddy_id = ? limit 1;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId, $buddyId));

  $row = $stmt->fetch();
  $count = $row[0];

  if ($count == 1) {
		die("Cannot block account again");
  }

  $query = "insert into block (user_id, buddy_id, block_time) values (?, ?, current_timestamp);";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId, $buddyId));

	$pdo = null;
?>

