<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $conn = mysqli_connect(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_DATABASE);

  $username = $_POST["username"];
  $password = $_POST["password"];
  $fcm = $_POST["fcm"];

	$isValid =
		isAuthenticated($username, $password) &&
		isValidString($fcm, 0, 1000);
	if ($isValid === False) {
		die("Invalid");
	}

  $query = "update users set fcm = ? where username = ?;";
  $stmt = $conn->prepare($query);
  $stmt->bind_param("ss", $fcm, $username);
  $stmt->execute();
?>

