<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $conn = mysqli_connect(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_DATABASE);

  $username = $_POST["username"];
  $password = $_POST["password"];
  $buddyUsername = $_POST["buddyUsername"];
  $reason = (int)$_POST["reason"];
  $otherReason = $_POST["otherReason"];

	$isValid =
		isAuthenticated($username, $password) &&
		isExistentUsername($buddyUsername) &&
		isValidInt($reason, 0, 3) &&
		isValidString($otherReason, 0, 1000);
	if ($isValid === False) {
		die("Invalid");
	}

  $query = "insert into reports (username, buddyUsername, reason, otherReason, reportTime) values (?, ?, ?, ?, current_timestamp);";
  $stmt = $conn->prepare($query);
  $stmt->bind_param("ssss", $username, $buddyUsername, $reason, $otherReason);
  $stmt->execute();
?>

