<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $conn = mysqli_connect(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_DATABASE);

  $username = $_POST["username"]; // do not choose the user himself
  $password = $_POST["password"]; // do not choose the user himself
  $gender = (int)$_POST["gender"]; // -1 = all, 0 = male, 1 = female, 2 = other
  $minAge = (int)$_POST["minAge"];
  $maxAge = (int)$_POST["maxAge"];
  $country = (int)$_POST["country"]; // -1 = all, 0 = Afghanistan, ... 196 = Zimbabwe
  $hasImage = toBool($_POST["hasImage"]); // False = all, True = image cannot be ""
  $hasGitHub = toBool($_POST["hasGitHub"]); // False = all, True = gitHub cannot be ""
  $hasLinkedIn = toBool($_POST["hasLinkedIn"]); // False = all, True = linkedIn cannot be ""
  $interests = $_POST["interests"]; // interests example: "&C++&&Python&&SwiftUI&"
  $level = (int)$_POST["level"]; // -1 = all, 0 = beginner, 1 = experienced
  $sort = (int)$_POST["sort"]; // 0 = sort by lastVisit, 1 = sort by lastUpdate, 2 = sort by accountCreation
  $lastSearchDate = $_POST["lastSearchDate"];

	$isValid =
		isAuthenticated($username, $password) &&
		isValidInt($gender, -1, 2) &&
		isValidInt($minAge, 0, 100) &&
		isValidInt($maxAge, $minAge, 100) &&
		isValidInt($country, -1, 196) &&
		isValidString($interests, 0, 1000) &&
		isValidInt($level, -1, 1) &&
		isValidInt($sort, 0, 2) &&
		isValidDate($lastSearchDate, True);
	if ($isValid === False) {
		die("Invalid");
	}

  $query = "select username, image, birthday, gender, left(interests, 50), left(intro, 50), char_length(gitHub), char_length(linkedIn), ";
  if ($sort === 0) {
    $query .= "lastVisit ";
  } else if ($sort === 1) {
    $query .= "lastUpdate ";
  } else {
    $query .= "accountCreation ";
  }
  $query .= "from users where not username = ? and isInvisible = 0 ";
  $paramsString = "s";
  $paramsArray = array($username);

  if ($gender !== -1) {
    $query .= "and gender = ? ";
    $paramsString .= "s";
    array_push($paramsArray, $gender);
  }

	if ($minAge != 13 || $maxAge != 80) {
		$maxAge += 1;
  	$minDate = date("Y-m-d", strtotime("-{$maxAge} years"));
  	$maxDate = date("Y-m-d", strtotime("-{$minAge} years"));
  	$query .= "and birthday between ? and ? ";
  	$paramsString .= "ss";
  	array_push($paramsArray, $minDate, $maxDate);
	}

  if ($country !== -1) {
    $query .= "and country = ? ";
    $paramsString .= "s";
    array_push($paramsArray, $country);
  }

  if ($hasGitHub) {
    $query .= "and not char_length(gitHub) = 0 ";
  }

  if ($hasLinkedIn) {
    $query .= "and not char_length(linkedIn) = 0 ";
  }

  if ($hasImage) {
    $query .= "and not char_length(image) = 0 ";
  }

  if (strlen($interests)) {
    $query .= "and interests like ? ";
    $paramsString .= "s";
    $likeQuery = "%";

		$interests = substr($interests, 1, -1);
    $interestsArray = explode("&&", $interests);
    foreach ($interestsArray as $interest) {
      $likeQuery .= "&".$interest."&%";
    }
    array_push($paramsArray, $likeQuery);
  }

  if ($level !== -1) {
    $query .= "and level = ? ";
    $paramsString .= "s";
    array_push($paramsArray, $level);
  }

  if ($sort === 0) {
    $query .= "and lastVisit < ? order by lastVisit desc ";
    array_push($paramsArray, $lastSearchDate);
  } else if ($sort === 1) {
    $query .= "and lastUpdate < ? order by lastUpdate desc ";
    array_push($paramsArray, $lastSearchDate);
  } else {
    $query .= "and accountCreation < ? order by accountCreation desc ";
    array_push($paramsArray, $lastSearchDate);
  }
  $query .= "limit 20;";
  $paramsString .= "s";

  $stmt = $conn->prepare($query);
  $stmt->bind_param($paramsString, ...$paramsArray);
  $stmt->execute();
  $result = $stmt->get_result() or die("Error");

  header("Content-type:application/json");

  $counter = 1; // PHP arrays start from 1
  $rows = array();
  while($row = mysqli_fetch_array($result)) {
    $rows[$counter++] = array(
      "username" => $row[0],
      "image" => $row[1],
      "birthday" => $row[2],
      "gender" => $row[3],
      "shortInterests" => $row[4],
      "shortIntro" => $row[5],
      "hasGitHub" => !empty($row[6]),
      "hasLinkedIn" => !empty($row[7]),
    );

		$lastSearchDate = min($lastSearchDate, $row[8]);
  }

  $rows[$counter++] = array(
    "lastSearchDate" => $lastSearchDate,
  );

  echo json_encode($rows);

  /*echo "QUERY: ".$query."\n";
  echo "String: ".$paramsString."\n";
  echo "ARRAY: ";
  print_r($paramsArray);*/
?>

