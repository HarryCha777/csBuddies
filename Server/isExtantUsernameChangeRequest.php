<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $password = $_POST["password"];

	$isValid =
		isAuthenticated($myId, $password);
	if (!$isValid) {
		die("Invalid");
	}

	$query = "select count(username_change_request_id) from username_change_request where user_id = ? and is_reviewed = false limit 1;";
	$stmt = $pdo->prepare($query);
	$stmt->execute(array($myId));

  $row = $stmt->fetch();
	$count = $row[0];
	
	if ($count == 1) {
    $return = array("isExtantUsernameChangeRequest" => True);
	} else {
    $return = array("isExtantUsernameChangeRequest" => False);
	}

  echo json_encode($return);

	$pdo = null;
?>
