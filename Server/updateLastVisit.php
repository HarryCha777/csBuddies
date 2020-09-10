<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $conn = mysqli_connect(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_DATABASE);

  $username = $_POST["username"];
  $password = $_POST["password"];

	$isValid =
		isAuthenticated($username, $password);
	if ($isValid === False) {
		die("Invalid");
	}

  $query = "update users set lastVisit = current_timestamp where username = ?;";
  $stmt = $conn->prepare($query);
  $stmt->bind_param("s", $username);
  $stmt->execute();
?>

