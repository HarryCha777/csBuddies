<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $conn = mysqli_connect(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_DATABASE);

  $guestId = $_POST["guestId"];

	/*$isValid =
		isValidString($guestId, 0, 300);
	if ($isValid === False) {
		die("Invalid");
	}*/

  $query = "insert into guests (guestId, firstLaunchTime) values (?, current_timestamp);";
  $stmt = $conn->prepare($query);
  $stmt->bind_param("s", $guestId);
  $stmt->execute();
?>

