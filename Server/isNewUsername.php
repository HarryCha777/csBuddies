<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $conn = mysqli_connect(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_DATABASE);

  $username = $_POST["username"];

	if (isNewUsername($username)) {
    $return = array("isNewUsername" => True);
  } else {
    $return = array("isNewUsername" => False);
  }
  echo json_encode($return);
?>


