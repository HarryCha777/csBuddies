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
		die("Invalid");
	}

  $query = "insert into message (user_id, buddy_id, content, send_time) values (?, ?, ?, current_timestamp) returning message_id;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId, $buddyId, $content));

  $row = $stmt->fetch();
  $messageId = $row[0];

  $query = "select fcm, badges from account where user_id = ?;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($buddyId));

  $row = $stmt->fetch();
	$fcm = $row[0];
	$badges = $row[1];

  $query = "update account set badges = badges + 1 where user_id = ?;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($buddyId));

  $return = array(
    "messageId" => $messageId,
    "fcm" => $fcm,
    "badges" => $badges,
  );
  echo json_encode($return);

	$pdo = null;
?>

