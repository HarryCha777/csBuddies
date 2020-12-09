<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $password = $_POST["password"];
  $byteId = $_POST["byteId"];
  $buddyId = $_POST["buddyId"];

	$isValid =
		isAuthenticated($myId, $password) &&
		isExtantByteId($byteId) &&
		isExtantUserId($buddyId);
	if (!$isValid) {
		die("Invalid");
	}

  $query = "select count(byte_id) from byte where user_id = ? and byte_id = ? limit 1;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId, $byteId));

  $row = $stmt->fetch();
	$count = $row[0];
	
  if ($count == 1) {
		die("Cannot like user's own byte");
	}

  $query = "select count(byte_like_id), is_liked from byte_like where user_id = ? and byte_id = ? group by byte_like_id limit 1;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId, $byteId));

  $row = $stmt->fetch();
	$count = $row[0];
	$hasAlreadyLiked = $count == 1 && $row[1];

  if ($count == 1) {
  	$query = "update byte_like set like_time = current_timestamp, is_liked = true where user_id = ? and byte_id = ?;";
  	$stmt = $pdo->prepare($query);
  	$stmt->execute(array($myId, $byteId));

		$isFirstLike = False;
	} else {
  	$query = "insert into byte_like (user_id, byte_id, like_time) values (?, ?, current_timestamp);";
  	$stmt = $pdo->prepare($query);
  	$stmt->execute(array($myId, $byteId));

		$isFirstLike = True;

  	$query = "select fcm, badges from account where user_id = ? limit 1;";
  	$stmt = $pdo->prepare($query);
  	$stmt->execute(array($buddyId));

  	$row = $stmt->fetch();
		$fcm = $row[0];
		$badges = $row[1];

  	$query = "update account set badges = badges + 1 where user_id = ?;";
  	$stmt = $pdo->prepare($query);
  	$stmt->execute(array($buddyId));
	}

	if (!$hasAlreadyLiked) {
  	$query = "update byte set likes = likes + 1 where byte_id = ?;";
  	$stmt = $pdo->prepare($query);
  	$stmt->execute(array($byteId));
	}

	$return = array(
		"hasAlreadyLiked" => $hasAlreadyLiked,
		"isFirstLike" => $isFirstLike,
		"fcm" => $fcm,
		"badges" => $badges,
	);

	echo json_encode($return);

	$pdo = null;
?>

