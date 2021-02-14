<?php
  require "globalFunctions.php";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $token = $_POST["token"];

	$isValid =
		isAuthenticated($myId, $token);
	if (!$isValid) {
  	$pdo = null;
		die("Invalid");
	}

  $query = "update account set user_outdated_at = null where user_id = ?;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId));

  $query = "select count(byte_id) from byte where deleted_at is null and user_id = ? limit 1;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId));

  $row = $stmt->fetch();
	$bytesMade = $row[0];

  $query = "select count(comment_id) from comment where deleted_at is null and user_id = ? limit 1;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId));

  $row = $stmt->fetch();
	$commentsMade = $row[0];

  $query = "select count(byte_like_id) from byte_like where is_liked = true and user_id = ? limit 1;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId));

  $row = $stmt->fetch();
	$byteLikesGiven = $row[0];

  $query = "select count(comment_like_id) from comment_like where is_liked = true and user_id = ? limit 1;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId));

  $row = $stmt->fetch();
	$commentLikesGiven = $row[0];

  $query = "select buddy_id from block where user_id = ?;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId));

  $counter = 1; // PHP arrays start from 1
  $blockedBuddyIds = array();
  while($row = $stmt->fetch()) {
    $blockedBuddyIds[$counter++] = array(
      "buddyId" => $row[0],
    );
  }

  $query = "select username, small_image, big_image, gender, birthday, country, interests, other_interests, intro, github, linkedin, notify_likes, notify_comments, notify_messages from account where user_id = ? limit 1;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId));

  $row = $stmt->fetch();
  $return = array(
    "username" => $row[0],
    "smallImage" => $row[1],
    "bigImage" => $row[2],
    "gender" => $row[3],
    "birthday" => $row[4],
    "country" => $row[5],
    "interests" => $row[6],
    "otherInterests" => $row[7],
    "intro" => $row[8],
    "gitHub" => $row[9],
    "linkedIn" => $row[10],
    "notifyLikes" => $row[11],
    "notifyComments" => $row[12],
    "notifyMessages" => $row[13],
    "bytesMade" => $bytesMade,
    "commentsMade" => $commentsMade,
    "byteLikesGiven" => $byteLikesGiven,
    "commentLikesGiven" => $commentLikesGiven,
    "blockedBuddyIds" => $blockedBuddyIds,
  );
  echo json_encode($return);

	$pdo = null;
?>

