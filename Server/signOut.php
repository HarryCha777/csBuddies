<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $password = $_POST["password"];

	$isValid =
		isAuthenticated($myId, $password);
	if (!$isValid) {
  	$pdo = null;
		die("Invalid");
	}

 	$query = "select last_sign_in_time, is_premium from account where user_id = ? limit 1;";
 	$stmt = $pdo->prepare($query);
 	$stmt->execute(array($myId));

 	$row = $stmt->fetch();
 	$lastSignInTime = strtotime($row[0]);
 	$isPremium = $row[1];

	$oneWeekAgo = strtotime("-1 week");

	if (!$isPremium && $lastSignInTime > $oneWeekAgo) { 
		$return = array("isTooSoon" => True);
		echo json_encode($return);
		$pdo = null;
		exit;
	}

	$query = "update account set fcm = '', last_sign_out_time = current_timestamp where user_id = ?;";
	$stmt = $pdo->prepare($query);
	$stmt->execute(array($myId));

	$pdo = null;
?>
