<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $username = $_POST["username"];

	if (empty($myId)) {
		$myId = $emptyUuid;
	}

	if (isExtantUsername($myId, $username)) {
    $return = array("isExtantUsername" => True);
	} else {
    $return = array("isExtantUsername" => False);
	}

  echo json_encode($return);

	$pdo = null;
?>
