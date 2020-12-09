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

  $query = "select account.user_id, account.username, to_char(block.block_time, 'yyyy-mm-dd hh24:mi:ss.ms') from block left join account on block.buddy_id = account.user_id where block.user_id = ? order by block.block_time asc;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId));

  $counter = 1; // PHP arrays start from 1
  $rows = array();
  while($row = $stmt->fetch()) {
    $rows[$counter++] = array(
      "buddyId" => $row[0],
      "username" => $row[1],
      "blockTime" => $row[2],
    );
  }
  echo json_encode($rows);

	$pdo = null;
?>

