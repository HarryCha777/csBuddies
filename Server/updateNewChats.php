<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $conn = mysqli_connect(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_DATABASE);

  $username = $_POST["username"];
  $password = $_POST["password"];
  $newChats = (int)$_POST["newChats"];

	$isValid =
		isAuthenticated($username, $password) &&
		isValidInt($newChats, 0, 2);
	if ($isValid === False) {
		die("Invalid");
	}

  $query = "update users set lastNewChat = current_timestamp, newChats = ? where username = ?;";
  $stmt = $conn->prepare($query);
  $stmt->bind_param("ss", $newChats, $username);
  $stmt->execute();
?>

