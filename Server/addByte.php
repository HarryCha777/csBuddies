<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
	$pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $password = $_POST["password"];
  $content = $_POST["content"];

	$isValid =
		isAuthenticated($myId, $password) &&
		isValidString($content, 1, 256);
	if (!$isValid) {
  	$pdo = null;
		die("Invalid");
	}

  $query = "select last_post_time, bytes_today from account where user_id = ? limit 1;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId));

  $row = $stmt->fetch();
  $lastPostTime = $row[0];
  $bytesToday = $row[1];

	if (gmdate("Y-m-d") == date("Y-m-d", strtotime($lastPostTime))) {
		if ($bytesToday < 50) {
  		$query = "update account set bytes_today = bytes_today + 1 where user_id = ?;";
  		$stmt = $pdo->prepare($query);
  		$stmt->execute(array($myId));
		} else {
    		$return = array("canMakeByte" => False);
  			echo json_encode($return);
				$pdo = null;
				exit;
		}
	} else {
  	$query = "update account set bytes_today = 1, last_post_time = current_timestamp where user_id = ?;";
  	$stmt = $pdo->prepare($query);
  	$stmt->execute(array($myId));
	}

  $query = "insert into byte (user_id, content, likes, post_time, is_deleted) values (?, ?, 0, current_timestamp, false);";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId, $content));

  $pdo = null;
?>

