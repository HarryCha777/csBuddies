<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $conn = mysqli_connect(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_DATABASE);

  $buddyUsername = $_POST["buddyUsername"];
  $username = $_POST["username"];
  $password = $_POST["password"];

	$isValid =
		isExistentUsername($buddyUsername) &&
		isAuthenticated($username, $password);
	if ($isValid === False) {
		die("Invalid");
	}

	$paramUsername = "%&".$username."&%";

  $query = "select blocks from users where username = ? and blocks like ? limit 1;";
  $stmt = $conn->prepare($query);
  $stmt->bind_param("ss", $buddyUsername, $paramUsername);
  $stmt->execute();
  $result = $stmt->get_result() or die("Error");

  if (mysqli_num_rows($result) == 1) {
    $return = array("isBlocked" => True);
  } else {
    $return = array("isBlocked" => False);
  }
  echo json_encode($return);
?>

