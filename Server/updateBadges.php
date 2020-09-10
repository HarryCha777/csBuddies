<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $conn = mysqli_connect(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_DATABASE);

  $username = $_POST["username"];
  $badges = (int)$_POST["badges"];

	$isValid =
		isExistentUsername($username) &&
		isValidInt($badges, 0, 1000000);
	if ($isValid === False) {
		die("Invalid");
	}

  $query = "update users set badges = ? where username = ?;";
  $stmt = $conn->prepare($query);
  $stmt->bind_param("ss", $badges, $username);
  $stmt->execute();
?>

