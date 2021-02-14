<?php
  require "globalFunctions.php";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $token = $_POST["token"];
  $byteId = $_POST["byteId"];

	$isValid =
		isAuthenticated($myId, $token) &&
		isExtantByteId($byteId);
	if (!$isValid) {
  	$pdo = null;
		die("Invalid");
	}

  $query = "select is_liked from byte_like where user_id = ? and byte_id = ? limit 1;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId, $byteId));

  $row = $stmt->fetch();
	$isUnliked = !$row[0];

  $query = "update byte_like set last_updated_at = current_timestamp, is_liked = false where user_id = ? and byte_id = ?;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId, $byteId));

	$return = array(
		"isUnliked" => $isUnliked,
	);

	echo json_encode($return);

	$pdo = null;
?>

