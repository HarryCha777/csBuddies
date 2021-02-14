<?php
  require "globalFunctions.php";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $token = $_POST["token"];
  $buddyId = $_POST["buddyId"];
  $content = $_POST["content"];

	$isValid =
		isAuthenticated($myId, $token) &&
		isExtantUserId($buddyId) &&
		isValidString($content, 1, 1000);
	if (!$isValid) {
  	$pdo = null;
		die("Invalid");
	}

  $query = "select count(buddy_id) from (select distinct buddy_id from message where user_id = ? and date(sent_at) = current_date) as message;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId));

  $row = $stmt->fetch();
  $dailyChatBuddies = $row[0];

	if ($dailyChatBuddies >= 50) {
 			$return = array(
				"dailyLimit" => 50,
				"isTooMany" => True,
			);
			echo json_encode($return);
			$pdo = null;
			exit;
	}

  $query = "insert into message (user_id, buddy_id, content) values (?, ?, ?) returning message_id;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId, $buddyId, $content));

  $row = $stmt->fetch();
  $messageId = $row[0];

	sendNotification("message", $myId, $buddyId, $content);

  $return = array(
    "messageId" => $messageId
  );
  echo json_encode($return);

	$pdo = null;
?>

