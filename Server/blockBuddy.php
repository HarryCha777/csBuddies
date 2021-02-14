<?php
  require "globalFunctions.php";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $token = $_POST["token"];
  $buddyId = $_POST["buddyId"];

	$isValid =
		isAuthenticated($myId, $token) &&
		isExtantUserId($buddyId);
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

  $query = "select count(block_id) = 1 from block where user_id = ? and buddy_id = ? limit 1;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId, $buddyId));

  $row = $stmt->fetch();
  $isBlocked = $row[0];

	// Buddy might have already been blocked from another device.
  if (!$isBlocked) {
  	$query = "insert into block (user_id, buddy_id) values (?, ?);";
  	$stmt = $pdo->prepare($query);
  	$stmt->execute(array($myId, $buddyId));
  }

	$pdo = null;
?>

