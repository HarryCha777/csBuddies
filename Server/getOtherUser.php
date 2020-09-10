<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $conn = mysqli_connect(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_DATABASE);

  $username = $_POST["username"];
  $hasImage = toBool($_POST["hasImage"]);

	$isValid =
		isExistentUsername($username);
	if ($isValid === False) {
		die("Invalid");
	}

  if ($hasImage) {
		$image = getImage($username);
  } else {
		$image = "";
	}

  $query = "select gender, birthday, country, interests, level, intro, gitHub, linkedIn, lastVisit, lastUpdate, accountCreation, fcm, badges from users where username = ? limit 1;";
  $stmt = $conn->prepare($query);
  $stmt->bind_param("s", $username);
  $stmt->execute();
  $result = $stmt->get_result() or die("Error");

  $row = mysqli_fetch_array($result);
  $return = array(
    "image" => $image,
    "gender" => $row[0],
    "birthday" => $row[1],
    "country" => $row[2],
    "interests" => $row[3],
    "level" => $row[4],
    "intro" => $row[5],
    "gitHub" => $row[6],
    "linkedIn" => $row[7],
    "lastVisit" => $row[8],
    "lastUpdate" => $row[9],
    "accountCreation" => $row[10],
    "fcm" => $row[11],
    "badges" => $row[12],
  );
  echo json_encode($return);
?>

