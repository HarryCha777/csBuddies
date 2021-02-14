<?php
  require "globalFunctions.php";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $token = $_POST["token"];
  $commentId = $_POST["commentId"];

	$isValid =
		isAuthenticated($myId, $token) &&
		isExtantCommentId($commentId);
	if (!$isValid) {
  	$pdo = null;
		die("Invalid");
	}

  $query = "select is_liked from comment_like where user_id = ? and comment_id = ? limit 1;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId, $commentId));

  $row = $stmt->fetch();
	$isUnliked = !$row[0];

  $query = "update comment_like set last_updated_at = current_timestamp, is_liked = false where user_id = ? and comment_id = ?;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId, $commentId));

	$return = array(
		"isUnliked" => $isUnliked,
	);

	echo json_encode($return);

	$pdo = null;
?>

