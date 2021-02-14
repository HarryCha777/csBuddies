<?php
  require "globalFunctions.php";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $token = $_POST["token"];
  $buddyId = $_POST["buddyId"];
  $reason = (int)$_POST["reason"];
  $comments = $_POST["comments"];
  $mustReplacePrevious = $_POST["mustReplacePrevious"];

	$isValid =
		isAuthenticated($myId, $token) &&
		isExtantUserId($buddyId) &&
		isValidInt($reason, 0, 6) &&
		isValidString($comments, 0, 1000) &&
		isValidBool($mustReplacePrevious);
	if (!$isValid) {
  	$pdo = null;
		die("Invalid");
	}

	$query = "select count(user_id) = 1 from account where user_id = ? and became_admin_at is not null limit 1;";
	$stmt = $pdo->prepare($query);
	$stmt->execute(array($buddyId));

  $row = $stmt->fetch();
	$isAdmin = $row[0];

	if ($isAdmin) {
    $return = array("isAdmin" => True);
  	echo json_encode($return);
		$pdo = null;
		exit;
	}

	if (!toBool($mustReplacePrevious)) {
		$query = "select count(report_id) = 1 from report where user_id = ? and buddy_id = ? and reviewed_at is null limit 1;";
		$stmt = $pdo->prepare($query);
		$stmt->execute(array($myId, $buddyId));

  	$row = $stmt->fetch();
		$isExtantReport = $row[0];

		if ($isExtantReport) {
  	  $return = array("isExtantReport" => True);
  		echo json_encode($return);
			$pdo = null;
			exit;
		}
	}

	if (toBool($mustReplacePrevious)) {
  	$query = "delete from report where user_id = ? and buddy_id = ? and reviewed_at is null;";
  	$stmt = $pdo->prepare($query);
  	$stmt->execute(array($myId, $buddyId));
	}

  $query = "insert into report (user_id, buddy_id, reason, comments) values (?, ?, ?, ?);";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId, $buddyId, $reason, $comments));

	$pdo = null;
?>

