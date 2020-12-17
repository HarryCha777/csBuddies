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

  $query = "select count(byte_like_id), is_liked from byte_like where user_id = ? and byte_id = ? group by byte_like_id limit 1;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId, $byteId));

  $row = $stmt->fetch();
	$hasLikedBefore = $row[0] == 1;
	$isLiked = $hasLikedBefore && $row[1];

  if ($hasLikedBefore) {
  	$query = "update byte_like set like_time = current_timestamp, is_liked = true where user_id = ? and byte_id = ?;";
  	$stmt = $pdo->prepare($query);
  	$stmt->execute(array($myId, $byteId));
	} else {
  	$query = "insert into byte_like (user_id, byte_id, like_time) values (?, ?, current_timestamp);";
  	$stmt = $pdo->prepare($query);
  	$stmt->execute(array($myId, $byteId));

  	$query = "select count(block_id) from block where user_id = ? and buddy_id = ? limit 1;";
  	$stmt = $pdo->prepare($query);
  	$stmt->execute(array($buddyId, $myId));

  	$row = $stmt->fetch();
		$isBlocked = $row[0] == 1;

  	$query = "select has_byte_notification from account where user_id = ? limit 1;";
  	$stmt = $pdo->prepare($query);
  	$stmt->execute(array($buddyId));

  	$row = $stmt->fetch();
		$hasByteNotification = $row[0];

		if (!$isBlocked && $hasByteNotification) {
  		$query = "select username, fcm from account where user_id = ? limit 1;";
  		$stmt = $pdo->prepare($query);
  		$stmt->execute(array($buddyId));

  		$row = $stmt->fetch();
			$username = $row[0];
			$fcm = $row[1];

  		$query = "select content from byte where byte_id = ? limit 1;";
  		$stmt = $pdo->prepare($query);
  		$stmt->execute(array($byteId));

  		$row = $stmt->fetch();
			$content = $row[0];

			sendNotification($fcm, $username, "$username liked your byte: $content", true, -1, $myId, "byte");
		}
	}

	if (!$isLiked) {
  	$query = "update byte set likes = likes + 1 where byte_id = ?;";
  	$stmt = $pdo->prepare($query);
  	$stmt->execute(array($byteId));
	}

	$return = array(
		"isLiked" => $isLiked
	);

	echo json_encode($return);

	$pdo = null;
?>

