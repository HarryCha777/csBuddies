<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $conn = mysqli_connect(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_DATABASE);

  $username = $_POST["username"];
  $password = $_POST["password"];
  $buddyUsername = $_POST["buddyUsername"];

	$isValid =
		isAuthenticated($username, $password) &&
		isExistentUsername($buddyUsername);
	if ($isValid === False) {
		die("Invalid");
	}

  $query = "delete from blocks where username = ? and buddyUsername = ?;";
  $stmt = $conn->prepare($query);
  $stmt->bind_param("ss", $username, $buddyUsername);
  $stmt->execute();
?>

