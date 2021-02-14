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

  $query = "delete from block where user_id = ? and buddy_id = ?;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId, $buddyId));

	$pdo = null;
?>

