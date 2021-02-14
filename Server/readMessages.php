<?php
  require "globalFunctions.php";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $token = $_POST["token"];
  $buddyId = $_POST["buddyId"];

	$isValid =
		isAuthenticated($myId, $token) &&
		isExtantUserId($buddyId);
	if (!$isValid) {
  	$pdo = null;
		die("Invalid");
	}

  $query = "select count(read_receipt_id) = 1 from read_receipt where user_id = ? and buddy_id = ? limit 1;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId, $buddyId));

  $row = $stmt->fetch();
  $hasReadReceipt = $row[0];

  if (!$hasReadReceipt) {
  	$query = "insert into read_receipt (user_id, buddy_id) values (?, ?);";
  	$stmt = $pdo->prepare($query);
  	$stmt->execute(array($myId, $buddyId));
  } else {
  	$query = "update read_receipt set last_read_at = current_timestamp where user_id = ? and buddy_id = ?;";
  	$stmt = $pdo->prepare($query);
  	$stmt->execute(array($myId, $buddyId));
	}

	$pdo = null;
?>

