<?php
	include "/var/www/inc/dbinfo.inc";

	$emptyUuid = "00000000-0000-0000-0000-000000000000";

	function isValidBool($string) {
		return $string == "true" || $string == "false";
	}

	function toBool($string) {
		// True in "true" in Swift.
		return $string == "true";
	}

	function isValidDate($date, $hasTime) {
		$format = $hasTime ? "Y-m-d H:i:s.u" : "Y-m-d";
		$d = DateTime::createFromFormat($format, $date);
		$dateNow = date($format);

		if ($d &&
			$d->format($format) == $date &&
			$date <= $dateNow) {
			return True;
		}
		return False;
	}

	function isValidInt($int, $minValue, $maxValue) {
		if ($minValue <= $int &&
			$int <= $maxValue) {
  	  return True;
		}
    return False;
	}

	function isValidString($string, $minLength, $maxLength) {
		if ($minLength <= strlen(utf8_decode($string)) &&
			strlen(utf8_decode($string)) <= $maxLength) {
	    return True;
		}
	  return False;
	}

	function isValidInterests($interests) {
		$interests = substr($interests, 1, -1);
    $interestsArray = explode("&&", $interests);

		if (isValidString($interests, 0, 1000) &&
			count($interestsArray) <= 10) {
			return True;
		}
		return False;
	}

	function isValidUsername($username) {
		if (6 <= strlen(utf8_decode($username)) &&
			strlen(utf8_decode($username)) <= 20 &&
			!startsWith($username, " ") &&
			!endsWith($username, " ") &&
			!strpos($username, "  ") &&
			ctype_alnum(str_replace(array(" "), "", $username))) {
			return True;
		}
		return False;
	}

	function startsWith($string, $startString) {
	  return substr_compare($string, $startString, 0, strlen(utf8_decode($startString))) == 0;
	}

	function endsWith($string, $endString) {
	  return substr_compare($string, $endString, -strlen(utf8_decode($endString))) == 0;
	}

	function isExtantUserId($userId) {
		$pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);
	  $query = "select count(user_id) from account where user_id = ? limit 1;";
	  $stmt = $pdo->prepare($query);
	  $stmt->execute(array($userId));

    $row = $stmt->fetch();
	  return $row[0] == 1;
	}

	function isExtantUsername($myId, $username) {
		$pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);
	  $query = "select count(user_id) from account where not user_id = ? and username = ? limit 1;";
	  $stmt = $pdo->prepare($query);
	  $stmt->execute(array($myId, $username));
	
    $row = $stmt->fetch();
	  return $row[0] == 1;
	}

	function isExtantByteId($byteId) {
		$pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);
	  $query = "select count(byte_id) from byte where byte_id = ? limit 1;";
	  $stmt = $pdo->prepare($query);
	  $stmt->execute(array($byteId));
	
    $row = $stmt->fetch();
	  return $row[0] == 1;
	}

	// When checking isAuthenticated, there is no need to check if userId and password are valid.
	function isAuthenticated($myId, $password, $mustBeActive = true) {
		$pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

	  $query = "select count(user_id) from account where user_id = ? and password = ? ";
		$query .= $mustBeActive ? "and is_banned = false and is_deleted = false " : "";
		$query .= "limit 1;";

	  $stmt = $pdo->prepare($query);
	  $stmt->execute(array($myId, $password));

    $row = $stmt->fetch();
	  return $row[0] == 1;
	}

	function sendNotification($fcm, $title, $body, $hasNotification, $badges, $myId, $type) {
  	$serverKey = getenv("FIREBASE_SERVER_KEY");

		$notification = array();
		if ($hasNotification) {
			$notification = array (
				"title"	=> $title,
				"body" => $body,
				"sound"	=> "default",
			);
		}

		if ($badges != -1) {
			$notification["badge"] = $badges + 1;
		}
		
		$fields = array (
			"registration_ids" => array($fcm),
			"priority" => "high",
			"notification" => $notification,
			"data" => array("myId" => $myId, "type" => $type)
		);
		 
		$headers = array (
			"Authorization: key=$serverKey",
			"Content-Type: application/json"
		);
		 
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, "https://fcm.googleapis.com/fcm/send");
		curl_setopt($ch, CURLOPT_POST, true);
		curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
		curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($fields));
		curl_exec($ch);
		curl_close($ch);
	}
?>

