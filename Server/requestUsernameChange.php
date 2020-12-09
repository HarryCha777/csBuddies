<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $password = $_POST["password"];
  $newUsername = $_POST["newUsername"];
  $reason = $_POST["reason"];
  $comments = $_POST["comments"];

	$isValid =
		isAuthenticated($myId, $password) &&
		isValidUsername($newUsername) &&
		!isExtantUsername($emptyUuid, $newUsername) &&
		isValidString($reason, 0, 100) &&
		isValidString($comments, 0, 1000);
	if (!$isValid) {
		die("Invalid");
	}

  $query = "delete from username_change_request where user_id = ? and is_reviewed = false;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId));

	$query = "select username from account where user_id = ? limit 1;";
	$stmt = $pdo->prepare($query);
	$stmt->execute(array($myId));
	
  $row = $stmt->fetch();
	$username = $row[0];

  $query = "insert into username_change_request (user_id, username, new_username, reason, comments, request_time) values (?, ?, ?, ?, ?, current_timestamp);";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId, $username, $newUsername, $reason, $comments));

	$pdo = null;
?>

