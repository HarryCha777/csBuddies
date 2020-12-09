<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $password = $_POST["password"];

	$isValid =
		isAuthenticated($myId, $password);
	if (!$isValid) {
		die("Invalid");
	}

  $query = "select account.user_id, to_char(account.last_visit_time, 'yyyy-mm-dd hh24:mi:ss.ms') from account left join message on account.user_id = message.buddy_id where message.user_id = ? group by account.user_id;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId));

  $counter = 1; // PHP arrays start from 1
  $rows = array();
  while($row = $stmt->fetch()) {
    $rows[$counter++] = array(
      "buddyId" => $row[0],
      "lastVisitTime" => $row[1],
    );
  }

  echo json_encode($rows);

	$pdo = null;
?>
