<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $password = $_POST["password"];
  $buddyId = $_POST["buddyId"];

	$isValid =
		isAuthenticated($myId, $password);
	if (!$isValid) {
		die("Invalid");
	}

	$query = "select count(report_id) from report where user_id = ? and buddy_id = ? limit 1;";
	$stmt = $pdo->prepare($query);
	$stmt->execute(array($myId, $buddyId));

  $row = $stmt->fetch();
	$count = $row[0];
	
	if ($count == 1) {
    $return = array("isExtantReport" => True);
	} else {
    $return = array("isExtantReport" => False);
	}

  echo json_encode($return);

	$pdo = null;
?>
