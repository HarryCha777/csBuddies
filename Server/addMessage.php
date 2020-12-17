<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
	$pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $password = $_POST["password"];
  $buddyId = $_POST["buddyId"];
  $content = $_POST["content"];

	$isValid =
		isAuthenticated($myId, $password) &&
		isExtantUserId($buddyId) &&
		isValidString($content, 1, 1000);
	if (!$isValid) {
  	$pdo = null;
		die("Invalid");
	}

  $query = "select count(message_id) from message where (user_id = ? and buddy_id = ?) or (user_id = ? and buddy_id = ?) limit 1;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId, $buddyId, $buddyId, $myId));

  $row = $stmt->fetch();
  $hasNeverMessagedBefore = $row[0] == 0;

	if ($hasNeverMessagedBefore) {
  	$query = "select last_first_chat_time, first_chats_today from account where user_id = ? limit 1;";
  	$stmt = $pdo->prepare($query);
  	$stmt->execute(array($myId));

  	$row = $stmt->fetch();
  	$lastFirstChatTime = $row[0];
  	$firstChatsToday = $row[1];

		if (gmdate("Y-m-d") == date("Y-m-d", strtotime($lastFirstChatTime))) {
			if ($firstChatsToday < 50) {
  			$query = "update account set first_chats_today = first_chats_today + 1 where user_id = ?;";
  			$stmt = $pdo->prepare($query);
  			$stmt->execute(array($myId));
			} else {
  	  		$return = array("canChat" => False);
  				echo json_encode($return);
					$pdo = null;
					exit;
			}
		} else {
  		$query = "update account set first_chats_today = 1, last_first_chat_time = current_timestamp where user_id = ?;";
  		$stmt = $pdo->prepare($query);
  		$stmt->execute(array($myId));
		}
	}

  $query = "select count(block_id) from block where user_id = ? and buddy_id = ? limit 1;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($buddyId, $myId));

  $row = $stmt->fetch();
	$isBlocked = $row[0] == 1;
	
	if ($isBlocked) {
  	$query = "select uuid_generate_v4() limit 1;";
  	$stmt = $pdo->prepare($query);
  	$stmt->execute();

  	$row = $stmt->fetch();
  	$messageId = $row[0];
	} else {
  	$query = "insert into message (user_id, buddy_id, content, send_time) values (?, ?, ?, current_timestamp) returning message_id;";
  	$stmt = $pdo->prepare($query);
  	$stmt->execute(array($myId, $buddyId, $content));

  	$row = $stmt->fetch();
  	$messageId = $row[0];

		$query = "select username, fcm, badges, has_chat_notification from account where user_id = ? limit 1;";
		$stmt = $pdo->prepare($query);
		$stmt->execute(array($buddyId));
		
		$row = $stmt->fetch();
		$username = $row[0];
		$fcm = $row[1];
		$badges = $row[2];
		$hasChatNotification = $row[3];

		$query = "update account set badges = badges + 1 where user_id = ?;";
		$stmt = $pdo->prepare($query);
		$stmt->execute(array($buddyId));

		sendNotification($fcm, $username, $content, $hasChatNotification, $badges, $myId, "chat");
	}

  $return = array(
    "messageId" => $messageId
  );
  echo json_encode($return);

	$pdo = null;
?>

