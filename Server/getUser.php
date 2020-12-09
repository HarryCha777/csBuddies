<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $password = $_POST["password"];

	$isValid =
		isAuthenticated($myId, $password);
	if (!$isValid) {
		die("Invalid");
	}

  $query = "update account set must_sync_with_server = false where user_id = ?;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId));

  $query = "select count(byte_id) from byte where is_deleted = false and user_id = ?;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId));

  $row = $stmt->fetch();
	$bytesMade = $row[0];

  $query = "select count(byte_like_id) from byte_like where is_liked = true and user_id = ?;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId));

  $row = $stmt->fetch();
	$likesGiven = $row[0];

  $query = "select email, username, small_image, big_image, gender, birthday, country, interests, other_interests, intro, git_hub, linked_in, to_char(last_post_time, 'yyyy-mm-dd hh24:mi:ss.ms'), bytes_today, to_char(last_first_chat_time, 'yyyy-mm-dd hh24:mi:ss.ms'), first_chats_today, to_char(last_received_chat_time, 'yyyy-mm-dd hh24:mi:ss.ms'), has_byte_notification, has_chat_notification from account where user_id = ? limit 1;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId));

  $row = $stmt->fetch();
  $return = array(
    "email" => $row[0],
    "username" => $row[1],
    "smallImage" => $row[2],
    "bigImage" => $row[3],
    "gender" => $row[4],
    "birthday" => $row[5],
    "country" => $row[6],
    "interests" => $row[7],
    "otherInterests" => $row[8],
    "intro" => $row[9],
    "gitHub" => $row[10],
    "linkedIn" => $row[11],
    "lastPostTime" => $row[12],
    "bytesToday" => $row[13],
    "lastFirstChatTime" => $row[14],
    "firstChatsToday" => $row[15],
    "lastReceivedChatTime" => $row[16],
    "bytesMade" => $bytesMade,
    "likesGiven" => $likesGiven,
    "hasByteNotification" => $row[17],
    "hasChatNotification" => $row[18],
  );
  echo json_encode($return);

	$pdo = null;
?>

