<?php
	include "/var/www/inc/dbinfo.inc";
	
  function getAnnouncement() {
    return "";
  }

  function getMinimumBuild() {
    return 1;
  }

	function toBool($string) {
		if ($string == "true") {
			return True;
		} else {
			return False;
		}
	}

	function isValidDate($date, $hasTime) {
		$format = $hasTime ? "Y-m-d H:i:s" : "Y-m-d";
		$d = DateTime::createFromFormat($format, $date);
		$dateNow = date($format);

		if ($d &&
			$d->format($format) === $date &&
			$date <= $dateNow) {
			return True;
		} else {
			return False;
		}
	}

	function isValidInt($int, $minValue, $maxValue) {
		if ($minValue <= $int &&
			$int <= $maxValue) {
  	  return True;
		} else {
  	  return False;
		}
	}

	function isValidString($string, $minLength, $maxLength) {
		if ($minLength <= strlen($string) &&
			strlen($string) <= $maxLength) {
	    return True;
		} else {
	    return False;
		}
	}

	function isValidLinkedIn($linkedIn) {
		if (strlen($linkedIn) == 0 ||
			startsWith($linkedIn, "https://www.linkedin.com/")) {
			return True;
		} else {
			return False;
		}
	}

	function isValidUsername($username) {
		if (6 <= strlen($username) &&
			strlen($username) <= 30 &&
			!startsWith($username, " ") &&
			!endsWith($username, " ") &&
			!strpos($username, "  ") &&
			ctype_alnum(str_replace(array("-", "_", " "), "", $username))) {
			return True;
		} else {
			return False;
		}
	}

	function isNewUsername($username) {
		$conn = mysqli_connect(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_DATABASE);
	  $query = "select username from users where username = ? limit 1;";
	  $stmt = $conn->prepare($query);
	  $stmt->bind_param("s", $username);
	  $stmt->execute();
	  $result = $stmt->get_result() or die("Error");
	
	  if (mysqli_num_rows($result) == 1) {
	    return False;
	  } else {
	    return True;
	  }
	}

	function isExistentUsername($username) {
		return !isNewUsername($username);
	}

	// When checking isAuthenticated, there is no need to check
	// isExistentUsername for username and isValidString for password.
	function isAuthenticated($username, $password) {
		$conn = mysqli_connect(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_DATABASE);
	  $query = "select username from users where username = ? and password = ? limit 1;";
	  $stmt = $conn->prepare($query);
	  $stmt->bind_param("ss", $username, $password);
	  $stmt->execute();
	  $result = $stmt->get_result() or die("Error");

	  if (mysqli_num_rows($result) == 1) {
	    return True;
	  } else {
	    return False;
	  }
	}

	function getImage($username) {
		$conn = mysqli_connect(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_DATABASE);
	  $query = "select image from users where username = ? limit 1;";
	  $stmt = $conn->prepare($query);
	  $stmt->bind_param("s", $username);
	  $stmt->execute();
	  $result = $stmt->get_result() or die("Error");

  	$row = mysqli_fetch_array($result);
    return $row[0];
	}

	function startsWith($string, $startString) {
	    return substr_compare($string, $startString, 0, strlen($startString)) === 0;
	}

	function endsWith($string, $endString) {
	    return substr_compare($string, $endString, -strlen($endString)) === 0;
	}
?>

