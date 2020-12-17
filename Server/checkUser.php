<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $password = $_POST["password"];

	$isValid =
		isAuthenticated($myId, $password, false);
	if (!$isValid) {
  	$pdo = null;
		die("Invalid");
	}

	$query = "update account set last_visit_time = current_timestamp where user_id = ?;";
	$stmt = $pdo->prepare($query);
	$stmt->execute(array($myId));

  $query = "select count(byte.user_id) from byte left join byte_like on byte.byte_id = byte_like.byte_id where byte.byte_id = byte_like.byte_id and byte_like.is_liked = true and byte.user_id = ? limit 1;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId));

  $row = $stmt->fetch();
  $likesReceived = $row[0];

  $query = "select is_premium, is_banned, must_sync_with_server from account where user_id = ? limit 1;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId));

  $row = $stmt->fetch();
  $return = array(
    "isPremium" => $row[0],
    "isBanned" => $row[1],
    "mustSyncWithServer" => $row[2],
    "likesReceived" => $likesReceived,
  );
  echo json_encode($return);

	$pdo = null;
?>

