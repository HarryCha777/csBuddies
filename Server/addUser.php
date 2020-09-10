<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $conn = mysqli_connect(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_DATABASE);

  $username = $_POST["username"];
  $password = $_POST["password"];
  $gender = (int)$_POST["gender"];
  $birthday = $_POST["birthday"];
  $country = (int)$_POST["country"];
  $interests = $_POST["interests"];
  $otherInterests = $_POST["otherInterests"];
  $level = (int)$_POST["level"];
  $intro = $_POST["intro"];
  $gitHub = $_POST["gitHub"];
  $linkedIn = $_POST["linkedIn"];

	$isValid =
		isValidUsername($username) &&
		isNewUsername($username) &&
		isValidString($password, 0, 1000) &&
		isValidInt($gender, 0, 2) &&
		isValidDate($birthday, False) &&
		isValidInt($country, 0, 196) &&
		isValidString($interests, 0, 1000) &&
		isValidString($otherInterests, 0, 100) &&
		isValidInt($level, 0, 1) &&
		isValidString($intro, 50, 1000) &&
		isValidString($gitHub, 0, 39) &&
		isValidString($linkedIn, 0, 100) &&
		isValidLinkedIn($linkedIn);
	if ($isValid === False) {
		die("Invalid");
	}

  $query = "insert into users (username, password, gender, birthday, country, interests, otherInterests, level, intro, gitHub, linkedIn, lastVisit, lastUpdate, accountCreation, lastNewChat) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, current_timestamp, current_timestamp, current_timestamp, current_timestamp);";
  $stmt = $conn->prepare($query);
  $stmt->bind_param("sssssssssss", $username, $password, $gender, $birthday, $country, $interests, $otherInterests, $level, $intro, $gitHub, $linkedIn);
  $stmt->execute();
?>

