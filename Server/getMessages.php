<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $password = $_POST["password"];
  $buddyId = $_POST["buddyId"];
  $lastReceivedChatTime = $_POST["lastReceivedChatTime"];

	$isValid =
		isAuthenticated($myId, $password) &&
		isExtantUserId($buddyId);
		//isValidDate($lastReceivedChatTime, True);
	if (!$isValid) {
		die("Invalid");
	}

  $query = "update account set last_received_chat_time = current_timestamp where user_id = ?;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId));

  $query = "select message_id, content, to_char(send_time, 'yyyy-mm-dd hh24:mi:ss.ms') from message where user_id = ? and buddy_id = ? and send_time > ? order by send_time asc;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($buddyId, $myId, $lastReceivedChatTime));

  $counter = 1; // PHP arrays start from 1
  $rows = array();
  while($row = $stmt->fetch()) {
    $rows[$counter++] = array(
      "messageId" => $row[0],
      "content" => $row[1],
      "sendTime" => $row[2],
    );
  }

  echo json_encode($rows);

	$pdo = null;
?>
