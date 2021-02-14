<?php
  require "globalFunctions.php";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $token = $_POST["token"];
  $content = $_POST["content"];

	$isValid =
		isAuthenticated($myId, $token) &&
		isValidString($content, 1, 256);
	if (!$isValid) {
  	$pdo = null;
		die("Invalid");
	}

  $query = "select count(byte_id) from byte where user_id = ? and date(posted_at) = current_date limit 1;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId));

  $row = $stmt->fetch();
  $dailyBytes = $row[0];

	if ($dailyBytes >= 50) {
   		$return = array(
				"dailyLimit" => 50,
				"isTooMany" => True,
			);
  		echo json_encode($return);
			$pdo = null;
			exit;
	}

  $query = "insert into byte (user_id, content) values (?, ?) returning byte_id;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId, $content));

  $row = $stmt->fetch();
  $byteId = $row[0];

  $return = array(
    "byteId" => $byteId
  );
  echo json_encode($return);

  $pdo = null;
?>

