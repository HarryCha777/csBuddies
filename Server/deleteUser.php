<?php
  require "globalFunctions.php";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $token = $_POST["token"];
  $reason = $_POST["reason"];
  $comments = $_POST["comments"];

	$isValid =
		isAuthenticated($myId, $token) &&
		isValidInt($reason, 0, 6) &&
		isValidString($comments, 0, 1000);
	if (!$isValid) {
  	$pdo = null;
		die("Invalid");
	}

  $query = "select count(user_id) = 1 from account where user_id = ? and deleted_at is not null limit 1;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId));

  $row = $stmt->fetch();
  $isDeleted = $row[0];

	if (!$isDeleted) {
  	$query = "update account set fcm = '', last_signed_out_at = current_timestamp, deleted_at = current_timestamp, deletion_reason = ?, deletion_comments = ? where user_id = ?;";
  	$stmt = $pdo->prepare($query);
  	$stmt->execute(array($reason, $comments, $myId));
	}

	$pdo = null;
?>

