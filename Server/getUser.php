<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $conn = mysqli_connect(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_DATABASE);

  $username = $_POST["username"];
  $password = $_POST["password"];
  $hasImage = toBool($_POST["hasImage"]);

	if (isNewUsername($username)) {
    $return = array("isNewUser" => True);
  	echo json_encode($return);
		exit;
	}

	$isValid =
		isAuthenticated($username, $password);
	if ($isValid === False) {
		die("Invalid");
	}

  $query = "update users set lastVisit = current_timestamp where username = ?;";
  $stmt = $conn->prepare($query);
  $stmt->bind_param("s", $username);
  $stmt->execute();

  $minimumBuild = getMinimumBuild();
  $announcement = getAnnouncement();

  if ($hasImage) {
		$image = getImage($username);
  } else {
		$image = "";
	}

  $query = "select gender, birthday, country, interests, otherInterests, level, intro, gitHub, linkedIn, lastVisit, lastUpdate, accountCreation, isBanned, blocks, lastNewChat, newChats, isPremium from users where username = ? limit 1;";
  $stmt = $conn->prepare($query);
  $stmt->bind_param("s", $username);
  $stmt->execute();
  $result = $stmt->get_result() or die("Error");

  $row = mysqli_fetch_array($result);
  $return = array(
    "isNewUser" => False,
    "minimumBuild" => $minimumBuild,
    "announcement" => $announcement,
    "image" => $image,
    "gender" => $row[0],
    "birthday" => $row[1],
    "country" => $row[2],
    "interests" => $row[3],
    "otherInterests" => $row[4],
    "level" => $row[5],
    "intro" => $row[6],
    "gitHub" => $row[7],
    "linkedIn" => $row[8],
    "lastVisit" => $row[9],
    "lastUpdate" => $row[10],
    "accountCreation" => $row[11],
    "isBanned" => $row[12],
    "blocks" => $row[13],
    "lastNewChat" => $row[14],
    "newChats" => $row[15],
    "isPremium" => $row[16],
  );
  echo json_encode($return);
?>

