<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $userId = $_POST["userId"];
  $bottomLikeTime = $_POST["bottomLikeTime"];

	if (empty($myId)) {
		$myId = $emptyUuid;
	}

	$isValid =
		isExtantUserId($userId);
		//isValidDate($bottomLikeTime, True);
	if (!$isValid) {
  	$pdo = null;
		die("Invalid");
	}

  $query = "select account.user_id, account.username, to_char(account.last_visit_time, 'yyyy-mm-dd hh24:mi:ss.ms'), byte.byte_id, byte.content, byte.likes, to_char(byte.post_time, 'yyyy-mm-dd hh24:mi:ss.ms'), case when byte_like_2.user_id = ? then true else false end, to_char(byte_like.like_time, 'yyyy-mm-dd hh24:mi:ss.ms') from byte left join byte_like on byte.byte_id = byte_like.byte_id left join byte_like as byte_like_2 on byte.byte_id = byte_like_2.byte_id and byte_like_2.user_id = ? left join account on byte.user_id = account.user_id where byte.is_invisible = false and byte.is_deleted = false and byte_like.is_liked = true and byte_like.user_id = ? and byte_like.like_time < ? order by byte_like.like_time desc limit 20;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId, $myId, $userId, $bottomLikeTime));

  $counter = 1; // PHP arrays start from 1
  $rows = array();
  while($row = $stmt->fetch()) {
    $rows[$counter++] = array(
      "userId" => $row[0],
      "username" => $row[1],
      "lastVisitTime" => $row[2],
      "byteId" => $row[3],
      "content" => $row[4],
      "likes" => $row[5],
      "postTime" => $row[6],
      "isLiked" => $row[7],
    );

		$bottomLikeTime = $row[8];
  }

  $rows[$counter++] = array(
    "bottomLikeTime" => $bottomLikeTime,
  );

  echo json_encode($rows);

	$pdo = null;
?>
