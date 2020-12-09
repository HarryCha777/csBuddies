<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $password = $_POST["password"];
  $byteId = $_POST["byteId"];

	$isValid =
		isAuthenticated($myId, $password);
		isExtantByteId($byteId);
	if (!$isValid) {
		die("Invalid");
	}

  $query = "select count(byte_id) from byte where is_deleted = false and byte_id = ? limit 1;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($byteId));

  $row = $stmt->fetch();
	$hasAlreadyDeleted = $row[0] == 0;

	if (!$hasAlreadyDeleted) {
  	$query = "update byte set is_deleted = true where byte_id = ?;";
  	$stmt = $pdo->prepare($query);
  	$stmt->execute(array($byteId));
	}

  $return = array("hasAlreadyDeleted" => $hasAlreadyDeleted);
	echo json_encode($return);

	$pdo = null;
?>

