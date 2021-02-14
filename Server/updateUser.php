<?php
  require "globalFunctions.php";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $token = $_POST["token"];
  $smallImage = $_POST["smallImage"];
  $bigImage = $_POST["bigImage"];
  $gender = (int)$_POST["gender"];
  $birthday = $_POST["birthday"];
  $country = (int)$_POST["country"];
  $interests = $_POST["interests"];
  $otherInterests = $_POST["otherInterests"];
  $intro = $_POST["intro"];
  $gitHub = $_POST["gitHub"];
  $linkedIn = $_POST["linkedIn"];

	$isValid =
		isAuthenticated($myId, $token) &&
		isValidString($smallImage, 1, 30000) &&
		isValidString($bigImage, 1, 300000) &&
		isValidInt($gender, 0, 3) &&
		isValidDate($birthday) &&
		isValidInt($country, 0, 196) &&
		isValidInterests($interests) &&
		isValidString($otherInterests, 0, 100) &&
		isValidString($intro, 1, 256) &&
		isValidString($gitHub, 0, 39) &&
		isValidString($linkedIn, 0, 100);
	if (!$isValid) {
  	$pdo = null;
		die("Invalid");
	}

	$query = "update account set small_image = ?, big_image = ?, gender = ?, birthday = ?, country = ?, interests = ?, other_interests = ?, intro = ?, github = ?, linkedin = ?, last_updated_at = current_timestamp, last_visited_at = current_timestamp where user_id = ?;";
	$stmt = $pdo->prepare($query);
	$stmt->execute(array($smallImage, $bigImage, $gender, $birthday, $country, $interests, $otherInterests, $intro, $gitHub, $linkedIn, $myId));

	$pdo = null;
?>
