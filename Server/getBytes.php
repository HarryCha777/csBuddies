<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $userId = $_POST["userId"];
  $bottomPostTime = $_POST["bottomPostTime"];

	if (empty($myId)) {
		$myId = $emptyUuid;
	}

	$isValid =
		isExtantUserId($userId);
		//isValidDate($bottomPostTime, True);
	if (!$isValid) {
  	$pdo = null;
		die("Invalid");
	}

  $query = "select to_char(account.last_visit_time, 'yyyy-mm-dd hh24:mi:ss.ms'), byte.byte_id, byte.content, byte.likes, to_char(byte.post_time, 'yyyy-mm-dd hh24:mi:ss.ms'), case when byte_like.user_id = ? then true else false end from byte left join account on account.user_id = byte.user_id left join byte_like on byte.byte_id = byte_like.byte_id and byte_like.is_liked = true and byte_like.user_id = ? where byte.is_invisible = false and byte.is_deleted = false and byte.user_id = ? and byte.post_time < ? order by byte.post_time desc limit 20;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId, $myId, $userId, $bottomPostTime));

  $counter = 1; // PHP arrays start from 1
  $rows = array();
  while($row = $stmt->fetch()) {
    $rows[$counter++] = array(
      "lastVisitTime" => $row[0],
      "byteId" => $row[1],
      "content" => $row[2],
      "likes" => $row[3],
      "postTime" => $row[4],
      "isLiked" => $row[5],
    );

		$bottomPostTime = $row[4];
  }

  $rows[$counter++] = array(
    "bottomPostTime" => $bottomPostTime,
  );

  echo json_encode($rows);

	$pdo = null;
?>
