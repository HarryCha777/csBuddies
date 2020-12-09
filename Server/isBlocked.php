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

  $query = "select count(block_id) from block where user_id = ? and buddy_id = ? limit 1;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($buddyId, $myId));

  $row = $stmt->fetch();
	$count = $row[0];
	
  if ($count == 1) {
    $return = array("isBlocked" => True);
  } else {
    $return = array("isBlocked" => False);
  }
  echo json_encode($return);

	$pdo = null;
?>

