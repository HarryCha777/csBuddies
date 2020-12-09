<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $password = $_POST["password"];
  $buddyId = $_POST["buddyId"];

	$isValid =
		isAuthenticated($myId, $password) &&
		isExtantUserId($buddyId);
	if (!$isValid) {
		die("Invalid");
	}

  $query = "delete from block where user_id = ? and buddy_id = ?;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId, $buddyId));

	$pdo = null;
?>

