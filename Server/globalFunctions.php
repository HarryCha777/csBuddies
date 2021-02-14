<?php
	// Use keyword must be specified at the global level, but they need to be included in each file instead of just global.
	use Kreait\Firebase\Factory;
	use Kreait\Firebase\ServiceAccount;

	require "/var/www/inc/dbConnection.php";
	$emptyUuid = "00000000-0000-0000-0000-000000000000";
	// $pdo cannot be a global variable since it changes.

	function isValidBool($string) {
		return $string == "true" || $string == "false";
	}

	function toBool($string) {
		// True in string is "true" in Swift.
		return $string == "true";
	}

	function isValidDate($string) {
		$format = "Y-m-d";
		$dateTime = DateTime::createFromFormat($format, $string);
		$now = date($format);

		if ($dateTime &&
			$dateTime->format($format) == $string &&
			$string <= $now) {
			return True;
		}
		return False;
	}

	function isValidTime($string) {
		// Append 3 zeroes and u for microseconds since v for milliseconds does not work for an unknown reason.
		$string .= "000";

		$format = "Y-m-d H:i:s.u";
		$dateTime = DateTime::createFromFormat($format, $string);

		// Add one extra second because date($format) does not work for microseconds for an unknown reason
		// and even if it does, current time fetched may be a couple milliseconds too slow.
		$now = (new \DateTime())->modify("+1 seconds")->format($format);

		if ($dateTime &&
			$dateTime->format($format) == $string &&
			$string <= $now) {
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

	  $query = "select count(user_id) = 1 from account where user_id = ? limit 1;";
	  $stmt = $pdo->prepare($query);
	  $stmt->execute(array($userId));

    $row = $stmt->fetch();
	  return $row[0];
	}

	function isExtantUsername($myId, $username) {
  	$pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

	  $query = "select count(user_id) = 1 from account where not user_id = ? and username = ? limit 1;";
	  $stmt = $pdo->prepare($query);
	  $stmt->execute(array($myId, $username));
	
    $row = $stmt->fetch();
	  return $row[0];
	}

	function isExtantByteId($byteId) {
  	$pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

	  $query = "select count(byte_id) = 1 from byte where byte_id = ? limit 1;";
	  $stmt = $pdo->prepare($query);
	  $stmt->execute(array($byteId));
	
    $row = $stmt->fetch();
	  return $row[0];
	}

	function isExtantCommentId($commentId) {
  	$pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

	  $query = "select count(comment_id) = 1 from comment where comment_id = ? limit 1;";
	  $stmt = $pdo->prepare($query);
	  $stmt->execute(array($commentId));
	
    $row = $stmt->fetch();
	  return $row[0];
	}

	function isExtantByteCommentId($byteId, $commentId) {
  	$pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

	  $query = "select count(comment_id) = 1 from comment where byte_id = ? and comment_id = ? limit 1;";
	  $stmt = $pdo->prepare($query);
	  $stmt->execute(array($byteId, $commentId));
	
    $row = $stmt->fetch();
	  return $row[0];
	}

	// When checking isAuthenticated, there is no need to check if userId is valid.
	function isAuthenticated($myId, $token, $mustBeActive = true) {
  	require "/var/www/inc/vendor/autoload.php";

		$factory = (new Factory)->withServiceAccount("/var/www/inc/firebaseAdminSdk.json");
		$auth = $factory->createAuth();

		try {
		  $verifiedIdToken = $auth->verifyIdToken($token);
		} catch (Exception $e) {
			return false;
		}

		$uid = $verifiedIdToken->claims()->get("sub");
		$claims = $auth->getUser($uid)->customClaims;
		$customClaimsUserId = $claims["userId"];

		if ($myId != $customClaimsUserId) {
			return false;
		}

  	$pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

	  $query = "select count(user_id) = 1 from account where user_id = ? ";
		$query .= $mustBeActive ? "and disabled_at is null and deleted_at is null " : "";
		$query .= "limit 1;";

	  $stmt = $pdo->prepare($query);
	  $stmt->execute(array($myId));

    $row = $stmt->fetch();
	  $isAuthenticated = $row[0];

		$query = "update account set last_visited_at = current_timestamp where user_id = ?;";
		$stmt = $pdo->prepare($query);
		$stmt->execute(array($myId));

		return $isAuthenticated;
	}

	function sendNotification($type, $myId, $buddyId, $content) {
  	$pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

		if ($myId == $buddyId) {
			return;
		}

  	$query = "select username, banned_at is not null from account where user_id = ? limit 1;";
  	$stmt = $pdo->prepare($query);
  	$stmt->execute(array($myId));

  	$row = $stmt->fetch();
		$username = $row[0];
		$isBanned = $row[1];

		switch ($type) {
    	case "byte like":
				$notificationName = "likes";
				$title = "{$username} liked your byte.";
    	  break;
    	case "comment like":
				$notificationName = "likes";
				$title = "{$username} liked your comment.";
    	  break;
    	case "byte comment":
				$notificationName = "comments";
				$title = "{$username} commented on your byte.";
    	  break;
    	case "comment reply":
				$notificationName = "comments";
				$title = "{$username} replied to your comment.";
    	  break;
    	case "message":
				$notificationName = "messages";
				$title = $username;
    	  break;
		}

		$query = "update account set badges = badges + 1 where user_id = ?;";
		$stmt = $pdo->prepare($query);
		$stmt->execute(array($buddyId));

  	$query = "select fcm, badges, notify_{$notificationName}, banned_at is not null from account where user_id = ? limit 1;";
  	$stmt = $pdo->prepare($query);
  	$stmt->execute(array($buddyId));

  	$row = $stmt->fetch();
		$fcm = $row[0];
		$badges = $row[1];
		$hasNotification = $row[2];
		$isBuddyBanned = $row[3];

  	$query = "select count(block_id) = 1 from block where user_id = ? and buddy_id = ? limit 1;";
  	$stmt = $pdo->prepare($query);
  	$stmt->execute(array($buddyId, $myId));

  	$row = $stmt->fetch();
		$isBlocked = $row[0];

		$notification = array();
		if ($hasNotification && !$isBanned && !$isBuddyBanned && !$isBlocked) {
			$notification = array (
				"title"	=> $title,
				"body" => $content,
				"sound"	=> "default",
			);
		}

		if ($badges != -1) {
			$notification["badge"] = $badges;
		}
		
		$fields = array (
			"registration_ids" => array($fcm),
			"priority" => "high",
			"notification" => $notification,
			"data" => array("myId" => $myId, "type" => $type)
		);
		 
  	$serverKey = getenv("FIREBASE_SERVER_KEY");
		$headers = array (
			"Authorization: key={$serverKey}",
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

