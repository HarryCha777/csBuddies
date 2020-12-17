<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $buddyId = $_POST["buddyId"];

	$isValid =
		isExtantUserId($buddyId);
	if (!$isValid) {
  	$pdo = null;
		die("Invalid");
	}

  $query = "select is_banned, is_deleted from account where user_id = ? limit 1;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($buddyId));

  $row = $stmt->fetch();
	$isBanned = $row[0];
	$isDeleted = $row[1];

	if (!$isBanned && !$isDeleted) {
	  $query = "select count(byte_id) from byte where is_deleted = false and user_id = ? limit 1;";
	  $stmt = $pdo->prepare($query);
	  $stmt->execute(array($buddyId));
	
	  $row = $stmt->fetch();
		$bytesMade = $row[0];
	
	  $query = "select count(byte.user_id) from byte left join byte_like on byte.byte_id = byte_like.byte_id where byte.byte_id = byte_like.byte_id and byte_like.is_liked = true and byte.user_id = ? limit 1;";
	  $stmt = $pdo->prepare($query);
	  $stmt->execute(array($buddyId));
	
	  $row = $stmt->fetch();
		$likesReceived = $row[0];
	
	  $query = "select count(user_id) from byte_like where is_liked = true and user_id = ? limit 1;";
	  $stmt = $pdo->prepare($query);
	  $stmt->execute(array($buddyId));
	
	  $row = $stmt->fetch();
		$likesGiven = $row[0];
	
	  $query = "select username, gender, birthday, country, interests, intro, git_hub, linked_in, to_char(last_visit_time, 'yyyy-mm-dd hh24:mi:ss.ms'), to_char(last_update_time, 'yyyy-mm-dd hh24:mi:ss.ms') from account where user_id = ? limit 1;";
	  $stmt = $pdo->prepare($query);
	  $stmt->execute(array($buddyId));
	}

  $row = $stmt->fetch();
  $return = array(
    "username" => $row[0],
    "gender" => $row[1],
    "birthday" => $row[2],
    "country" => $row[3],
    "interests" => $row[4],
    "intro" => $row[5],
    "gitHub" => $row[6],
    "linkedIn" => $row[7],
    "lastVisitTime" => $row[8],
    "lastUpdateTime" => $row[9],
    "bytesMade" => $bytesMade,
    "likesReceived" => $likesReceived,
    "likesGiven" => $likesGiven,
    "isBanned" => $isBanned,
    "isDeleted" => $isDeleted,
  );
  echo json_encode($return);

	$pdo = null;
?>

