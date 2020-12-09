<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $password = $_POST["password"];
  $buddyId = $_POST["buddyId"];
  $reason = (int)$_POST["reason"];
  $otherReason = $_POST["otherReason"];
  $comments = $_POST["comments"];

	$isValid =
		isAuthenticated($myId, $password) &&
		isExtantUserId($buddyId) &&
		isValidInt($reason, 0, 5) &&
		isValidString($otherReason, 0, 100) &&
		isValidString($comments, 0, 1000);
	if (!$isValid) {
		die("Invalid");
	}

  $query = "delete from report where user_id = ? and buddy_id = ? and is_reviewed = false;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId, $buddyId));

  $query = "insert into report (user_id, buddy_id, reason, other_reason, comments, report_time) values (?, ?, ?, ?, ?, current_timestamp);";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId, $buddyId, $reason, $otherReason, $comments));

	$pdo = null;
?>

