<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $byteId = $_POST["byteId"];
  $bottomLikeTime = $_POST["bottomLikeTime"];

	$isValid =
		isExtantByteId($byteId);
		//isValidDate($bottomLikeTime, True);
	if (!$isValid) {
  	$pdo = null;
		die("Invalid");
	}

  $query = "select account.user_id, account.username, to_char(account.last_visit_time, 'yyyy-mm-dd hh24:mi:ss.ms'), to_char(byte_like.like_time, 'yyyy-mm-dd hh24:mi:ss.ms') from byte_like left join account on byte_like.user_id = account.user_id where is_liked = true and byte_like.byte_id = ? and byte_like.like_time < ? order by byte_like.like_time desc limit 20;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($byteId, $bottomLikeTime));

  $counter = 1; // PHP arrays start from 1
  $rows = array();
  while($row = $stmt->fetch()) {
    $rows[$counter++] = array(
      "userId" => $row[0],
      "username" => $row[1],
      "lastVisitTime" => $row[2],
      "likeTime" => $row[3],
    );

		$bottomLikeTime = $row[3];
  }

  $rows[$counter++] = array(
    "bottomLikeTime" => $bottomLikeTime,
  );

  echo json_encode($rows);

	$pdo = null;
?>
