<?php
  require "globalFunctions.php";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $email = $_POST["email"];

	$isValid =
		isValidString($email, 3, 320);
	if (!$isValid) {
  	$pdo = null;
		die("Invalid");
	}

  $query = "select count(user_id) = 1 from account where lower(email) = lower(?) and deleted_at is not null limit 1;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($email));

  $row = $stmt->fetch();
  $isDeletedEmail = $row[0];

  $return = array(
    "isDeletedEmail" => $isDeletedEmail,
  );
  echo json_encode($return);
	$pdo = null;
?>
