<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $password = $_POST["password"];
  $byteId = $_POST["byteId"];

	$isValid =
		isAuthenticated($myId, $password) &&
		isExtantByteId($byteId);
	if (!$isValid) {
  	$pdo = null;
		die("Invalid");
	}

  $query = "select count(byte_id) from byte where user_id = ? and byte_id = ? limit 1;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId, $byteId));

  $row = $stmt->fetch();
  $isOwnByte = $row[0] == 1;
  
  if ($isOwnByte) {
  	$pdo = null;
		die("Invalid");
	}

  $query = "select is_liked from byte_like where user_id = ? and byte_id = ? limit 1;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId, $byteId));

  $row = $stmt->fetch();
	$isUnliked = $row[0] == 0;

  $query = "update byte_like set like_time = current_timestamp, is_liked = false where user_id = ? and byte_id = ?;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId, $byteId));

	if (!$isUnliked) {
  	$query = "update byte set likes = likes - 1 where byte_id = ?;";
  	$stmt = $pdo->prepare($query);
  	$stmt->execute(array($byteId));
	}

	$return = array(
		"isUnliked" => $isUnliked,
	);

	echo json_encode($return);

	$pdo = null;
?>

