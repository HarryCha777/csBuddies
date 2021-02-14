<?php
  require "globalFunctions.php";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $token = $_POST["token"];
  $byteId = $_POST["byteId"];
  $parentCommentId = $_POST["parentCommentId"];
  $content = $_POST["content"];

	if (empty($parentCommentId)) {
		$parentCommentId = $emptyUuid;
	}

	$isValid =
		isAuthenticated($myId, $token) &&
		isValidString($content, 1, 256) &&
		isExtantByteId($byteId) &&
		($parentCommentId == $emptyUuid || isExtantByteCommentId($byteId, $parentCommentId));
	if (!$isValid) {
  	$pdo = null;
		die("Invalid");
	}

  $query = "select count(comment_id) from comment where user_id = ? and date(posted_at) = current_date limit 1;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId));

  $row = $stmt->fetch();
  $dailyComments = $row[0];

	if ($dailyComments >= 100) {
   		$return = array(
				"dailyLimit" => 100,
				"isTooMany" => True,
			);
 			echo json_encode($return);
			$pdo = null;
			exit;
	}

  $query = "insert into comment (user_id, byte_id, parent_comment_id, content) values (?, ?, ?, ?) returning comment_id;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId, $byteId, $parentCommentId, $content));

  $row = $stmt->fetch();
  $commentId = $row[0];

	if ($parentCommentId == $emptyUuid) {
  	$query = "select user_id from byte where byte_id = ? limit 1;";
  	$stmt = $pdo->prepare($query);
  	$stmt->execute(array($byteId));

  	$row = $stmt->fetch();
  	$buddyId = $row[0];

		sendNotification("byte comment", $myId, $buddyId, $content);
	} else {
  	$query = "select user_id from comment where comment_id = ? limit 1;";
  	$stmt = $pdo->prepare($query);
  	$stmt->execute(array($parentCommentId));

  	$row = $stmt->fetch();
  	$buddyId = $row[0];

		sendNotification("comment reply", $myId, $buddyId, $content);
	}

  $return = array(
    "commentId" => $commentId
  );
  echo json_encode($return);

  $pdo = null;
?>

