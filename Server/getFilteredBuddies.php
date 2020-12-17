<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $gender = (int)$_POST["gender"]; // -1 = all, 0 = male, 1 = female, 2 = other
  $minAge = (int)$_POST["minAge"];
  $maxAge = (int)$_POST["maxAge"];
  $country = (int)$_POST["country"]; // -1 = all, 0 = Afghanistan, ... 196 = Zimbabwe
  $sort = (int)$_POST["sort"]; // 0 = active, 1 = new
  $interests = $_POST["interests"]; // interests example: "&C++&&Python&&SwiftUI&"
  $bottomLastVisitTime = $_POST["bottomLastVisitTime"];
  $bottomSignUpTime = $_POST["bottomSignUpTime"];

	if (empty($myId)) {
		$myId = $emptyUuid;
	}

  /*$query = "insert into time_format (timeFormatId, user_id, bottomLastVisitTime) values (uuid_to_bin(uuid(), true), ?, ?);";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId, $bottomLastVisitTime));*/

	$isValid =
		isValidInt($gender, -1, 2) &&
		isValidInt($minAge, 13, 130) &&
		isValidInt($maxAge, $minAge, 130) &&
		isValidInt($country, -1, 196) &&
		isValidInterests($interests) &&
		isValidInt($sort, 0, 1);
		//isValidDate($bottomLastVisitTime, True) &&
		//isValidDate($bottomSignUpTime, True);
	if (!$isValid) {
  	$pdo = null;
		die("Invalid");
	}

  $query = "select user_id, username, birthday, gender, intro, case when char_length(git_hub) > 0 then true else false end, case when char_length(linked_in) > 0 then true else false end, to_char(last_visit_time, 'yyyy-mm-dd hh24:mi:ss.ms'), to_char(sign_up_time, 'yyyy-mm-dd hh24:mi:ss.ms') from account where not user_id = ? and is_invisible = false and is_banned = false and is_deleted = false ";
	$paramsArray = array($myId);

  if ($gender != -1) {
    $query .= "and gender = ? ";
    array_push($paramsArray, $gender);
  }

	if ($minAge != 13 || $maxAge != 130) {
		$maxAge += 1;
  	$minDate = date("Y-m-d", strtotime("-{$maxAge} years"));
  	$maxDate = date("Y-m-d", strtotime("-{$minAge} years"));
  	$query .= "and birthday between ? and ? ";
  	array_push($paramsArray, $minDate, $maxDate);
	}

  if ($country != -1) {
    $query .= "and country = ? ";
    array_push($paramsArray, $country);
  }

	// Select buddies with OR interests.
  if (strlen($interests)) {
    $query .= "and (false ";

		$interests = substr($interests, 1, -1);
    $interestsArray = explode("&&", $interests);
    foreach ($interestsArray as $interest) {
      $query .= "or interests like ? ";
    	array_push($paramsArray, "%&".$interest."&%");
    }

		$query .= ") ";
	}

	// Select buddies with AND interests.
  /*if (strlen($interests)) {
    $query .= "and interests like ? ";
    $likeQuery = "%";

		$interests = substr($interests, 1, -1);
    $interestsArray = explode("&&", $interests);
    foreach ($interestsArray as $interest) {
      $likeQuery .= "&".$interest."&%";
    }
    array_push($paramsArray, $likeQuery);
  }*/

	if ($sort == 0) {
		# Hide new users who made their accounts up to 1 day ago
		# in order to prevent new users from cluttering active users sort and prevent mass spam of new user account.
  	//$query .= "and last_visit_time < ? and sign_up_time < current_date - interval '1 days' order by last_visit_time desc limit 20;";
  	$query .= "and last_visit_time < ? order by last_visit_time desc limit 20;";
  	array_push($paramsArray, $bottomLastVisitTime);
	} else {
  	$query .= "and sign_up_time < ? order by sign_up_time desc limit 20;";
  	array_push($paramsArray, $bottomSignUpTime);
	}

  $stmt = $pdo->prepare($query);
  $stmt->execute($paramsArray);

  $counter = 1; // PHP arrays start from 1
  $rows = array();
  while($row = $stmt->fetch()) {
    $rows[$counter++] = array(
      "buddyId" => $row[0],
      "username" => $row[1],
      "birthday" => $row[2],
      "gender" => $row[3],
      "intro" => $row[4],
      "hasGitHub" => $row[5],
      "hasLinkedIn" => $row[6],
      "lastVisitTime" => $row[7],
    );

		$bottomLastVisitTime = $row[7];
		$bottomSignUpTime = $row[8];
  }

  $rows[$counter++] = array(
    "bottomLastVisitTime" => $bottomLastVisitTime,
    "bottomSignUpTime" => $bottomSignUpTime,
  );

  echo json_encode($rows);

	$pdo = null;

  /*echo "QUERY: ".$query."\n";
  echo "ARRAY: ";
  print_r($paramsArray);*/
?>

