<?php
  require "globalFunctions.php";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $token = $_POST["token"];
  $userId = $_POST["userId"];
  $bottomPostedAt = $_POST["bottomPostedAt"];

	if (empty($myId)) {
		$myId = $emptyUuid;
	}

	$isValid =
		($myId == $emptyUuid || isAuthenticated($myId, $token)) &&
		isExtantUserId($userId) &&
		isValidTime($bottomPostedAt, True);
	if (!$isValid) {
  	$pdo = null;
		die("Invalid");
	}

  $query = "
		select byte.byte_id,
		       byte.content,
           coalesce(all_byte_like.likes, 0),
           coalesce(comment.comments, 0),
           case when my_byte_like.byte_like_id is null then false else true end,
		       byte.posted_at
		from   byte
           left join (select byte_id,
                             count(comment_id) as comments
                      from   comment
                      where  deleted_at is null
                      group  by byte_id) as comment
                  on comment.byte_id = byte.byte_id
           left join (select byte_id,
                             count(byte_like_id) as likes
                      from   byte_like
                      where  is_liked = true
                      group  by byte_id) as all_byte_like
                  on all_byte_like.byte_id = byte.byte_id
		       left join byte_like as my_byte_like
		              on my_byte_like.byte_id = byte.byte_id
		                 and my_byte_like.is_liked = true
		                 and my_byte_like.user_id = ?
		where  byte.deleted_at is null
		       and byte.user_id = ?
		       and byte.posted_at < ?
		order  by byte.posted_at desc
		limit  20;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId, $userId, $bottomPostedAt));

  $counter = 1; // PHP arrays start from 1
  $rows = array();
  while($row = $stmt->fetch()) {
    $rows[$counter++] = array(
      "byteId" => $row[0],
      "content" => $row[1],
      "likes" => $row[2],
      "comments" => $row[3],
      "isLiked" => $row[4],
      "postedAt" => $row[5],
    );

		$bottomPostedAt = $row[5];
  }

  $rows[$counter++] = array(
    "bottomPostedAt" => $bottomPostedAt,
  );

  echo json_encode($rows);

	$pdo = null;
?>
