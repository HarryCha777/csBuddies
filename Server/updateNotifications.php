<?php
  require "globalFunctions.php";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $token = $_POST["token"];
  $notifyLikes = $_POST["notifyLikes"];
  $notifyComments = $_POST["notifyComments"];
  $notifyMessages = $_POST["notifyMessages"];

	$isValid =
		isAuthenticated($myId, $token) &&
		isValidBool($notifyLikes) &&
		isValidBool($notifyComments) &&
		isValidBool($notifyMessages);
	if (!$isValid) {
  	$pdo = null;
		die("Invalid");
	}

  $query = "update account set notify_likes = ?, notify_comments = ?, notify_messages = ? where user_id = ?;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($notifyLikes, $notifyComments, $notifyMessages, $myId));

	$pdo = null;
?>

