<?php
	use Kreait\Firebase\Factory;
	use Kreait\Firebase\ServiceAccount;

  require "globalFunctions.php";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $token = $_POST["token"];
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
  $fcm = $_POST["fcm"];

	$isValid =
		isValidUsername($username) &&
		isValidString($smallImage, 1, 30000) &&
		isValidString($bigImage, 1, 300000) &&
		isValidInt($gender, 0, 3) &&
		isValidDate($birthday) &&
		isValidInt($country, 0, 196) &&
		isValidInterests($interests) &&
		isValidString($otherInterests, 0, 100) &&
		isValidString($intro, 1, 256) &&
		isValidString($gitHub, 0, 39) &&
		isValidString($linkedIn, 0, 100) &&
		isValidString($fcm, 0, 1000);
	if (!$isValid) {
  	$pdo = null;
		die("Invalid");
	}

	if (isExtantUsername($emptyUuid, $username)) {
    $return = array("isExtantUsername" => True);
  	echo json_encode($return);
		$pdo = null;
		exit;
	}

  require "/var/www/inc/vendor/autoload.php";

	$factory = (new Factory)->withServiceAccount("/var/www/inc/firebaseAdminSdk.json");
	$auth = $factory->createAuth();

	try {
	  $verifiedIdToken = $auth->verifyIdToken($token);
	} catch (Exception $e) {
  	$pdo = null;
		die("Invalid");
	}

	$uid = $verifiedIdToken->claims()->get("sub");
	if (!$auth->getUser($uid)->emailVerified) {
  	$pdo = null;
		die("Invalid");
	}

	$email = $auth->getUser($uid)->email;

  $query = "select count(user_id) = 1 from account where lower(email) = lower(?) limit 1;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($email));

  $row = $stmt->fetch();
  $isExtantEmail = $row[0];
  if ($isExtantEmail) {
  	$pdo = null;
		die("Invalid");
	}

 	$query = "insert into account (email, username, small_image, big_image, gender, birthday, country, interests, other_interests, intro, github, linkedin, fcm) values (lower(?), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) returning user_id;";
 	$stmt = $pdo->prepare($query);
	$stmt->execute(array($email, $username, $smallImage, $bigImage, $gender, $birthday, $country, $interests, $otherInterests, $intro, $gitHub, $linkedIn, $fcm));

  $row = $stmt->fetch();
  $myId = $row[0];

	$auth->setCustomUserClaims($uid, ["userId" => $myId]);

  $return = array(
    "myId" => $myId,
  );
  echo json_encode($return);
	$pdo = null;
?>
