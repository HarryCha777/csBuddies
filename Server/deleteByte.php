<?php
  require "globalFunctions.php";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $token = $_POST["token"];
  $byteId = $_POST["byteId"];

	$isValid =
		isAuthenticated($myId, $token) &&
		isExtantByteId($byteId);
	if (!$isValid) {
  	$pdo = null;
		die("Invalid");
	}

  $query = "select count(byte_id) = 0 from byte where deleted_at is null and byte_id = ? limit 1;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($byteId));

  $row = $stmt->fetch();
	$hasAlreadyDeleted = $row[0];

	if (!$hasAlreadyDeleted) {
  	$query = "update byte set deleted_at = current_timestamp where byte_id = ?;";
  	$stmt = $pdo->prepare($query);
  	$stmt->execute(array($byteId));
	}

  $return = array("hasAlreadyDeleted" => $hasAlreadyDeleted);
	echo json_encode($return);

	$pdo = null;
?>

