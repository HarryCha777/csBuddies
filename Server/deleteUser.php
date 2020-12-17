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

  $query = "update account set is_deleted = 1 where user_id = ?;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId));

	$pdo = null;
?>

