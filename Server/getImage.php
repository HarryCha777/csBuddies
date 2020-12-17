<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $userId = $_POST["userId"];
  $size = $_POST["size"];

	$isValid =
		isExtantUserId($userId) &&
		($size == "small" || $size == "big");
	if (!$isValid) {
  	$pdo = null;
		die("Invalid");
	}

	if ($size == "big") {
		$query = "select big_image from account where user_id = ? limit 1;";
		$stmt = $pdo->prepare($query);
		$stmt->execute(array($userId));
	} else {
		$query = "select small_image from account where user_id = ? limit 1;";
		$stmt = $pdo->prepare($query);
		$stmt->execute(array($userId));
	}

  $row = $stmt->fetch();
  $return = array(
    "image" => $row[0],
  );
  echo json_encode($return);

	$pdo = null;
?>
