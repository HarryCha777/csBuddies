<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $email = $_POST["email"];
  $username = $_POST["username"];
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
		isValidString($email, 3, 320) &&
		isValidUsername($username) &&
		!isExtantUsername($emptyUuid, $username) &&
		isValidString($smallImage, 1, 30000) &&
		isValidString($bigImage, 1, 300000) &&
		isValidInt($gender, 0, 3) &&
		//isValidDate($birthday, False) &&
		isValidInt($country, 0, 196) &&
		isValidInterests($interests) &&
		isValidInterests($otherInterests) &&
		isValidString($intro, 1, 256) &&
		isValidString($gitHub, 0, 39) &&
		isValidString($linkedIn, 0, 100);
	if (!$isValid) {
		die("Invalid");
	}

  $query = "select count(user_id) from account where email = ?;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($email));

  $row = $stmt->fetch();
  $count = $row[0];

	if ($count == 0) {
		$password = bin2hex(openssl_random_pseudo_bytes(6));

  	$query = "insert into account (email, username, password, small_image, big_image, gender, birthday, country, interests, other_interests, intro, git_hub, linked_in) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) returning user_id;";
  	$stmt = $pdo->prepare($query);
  	$stmt->execute(array($email, $username, $password, $smallImage, $bigImage, $gender, $birthday, $country, $interests, $otherInterests, $intro, $gitHub, $linkedIn));

    $row = $stmt->fetch();
    $myId = $row[0];
	}

  $return = array(
    "myId" => $myId,
    "password" => $password,
  );
  echo json_encode($return);

	$pdo = null;
?>
