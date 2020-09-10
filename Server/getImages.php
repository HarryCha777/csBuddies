<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $conn = mysqli_connect(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_DATABASE);

  $username = $_POST["username"];
  $password = $_POST["password"];
  $buddyUsernames = $_POST["buddyUsernames"];

	$isValid =
		isAuthenticated($username, $password) &&
		isValidString($buddyUsernames, 0, 1000000);
	if ($isValid === False) {
		die("Invalid");
	}

  $query = "select username, image from users where false ";
  $paramsString = "";
  $paramsArray = array();

	$buddyUsernames = substr($buddyUsernames, 1, -1);
  $buddyUsernamesArray = explode("&&", $buddyUsernames);
  foreach ($buddyUsernamesArray as $buddyUsername) {
		$query .= "or username = ? ";
		$paramsString .= "s";
    array_push($paramsArray, $buddyUsername);
  }
	$query .= ";";

  $stmt = $conn->prepare($query);
  $stmt->bind_param($paramsString, ...$paramsArray);
  $stmt->execute();
  $result = $stmt->get_result() or die("Error");

  $counter = 1; // PHP arrays start from 1
  $rows = array();
  while($row = mysqli_fetch_array($result)) {
    $rows[$counter++] = array(
      "username" => $row[0],
      "image" => $row[1],
    );
  }

  echo json_encode($rows);
?>
