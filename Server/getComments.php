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
		isValidTime($bottomPostedAt);
	if (!$isValid) {
  	$pdo = null;
		die("Invalid");
	}

  $query = "
		select comment.comment_id,
		       comment.byte_id,
		       coalesce(parent_account.user_id, '{$emptyUuid}'),
		       coalesce(parent_account.username, ''),
		       comment.content,
           coalesce(all_comment_like.likes, 0),
           case when my_comment_like.comment_like_id is null then false else true end,
		       comment.posted_at
		from   comment
           left join (select comment_id,
                             count(comment_like_id) as likes
                      from   comment_like
                      where  is_liked = true
                      group  by comment_id) as all_comment_like
                  on all_comment_like.comment_id = comment.comment_id
		       left join comment_like as my_comment_like
		              on my_comment_like.comment_id = comment.comment_id
		                 and my_comment_like.is_liked = true
		                 and my_comment_like.user_id = ?
		       left join comment as parent_comment
		              on parent_comment.comment_id = comment.parent_comment_id
		       left join account as parent_account
		              on parent_account.user_id = parent_comment.user_id
		where  comment.deleted_at is null
		       and comment.user_id = ?
		       and comment.posted_at < ?
		order  by comment.posted_at desc
		limit  20;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId, $userId, $bottomPostedAt));

  $counter = 1; // PHP arrays start from 1
  $rows = array();
  while($row = $stmt->fetch()) {
    $rows[$counter++] = array(
      "commentId" => $row[0],
      "byteId" => $row[1],
      "parentUserId" => $row[2],
      "parentUsername" => $row[3],
      "content" => $row[4],
      "likes" => $row[5],
      "isLiked" => $row[6],
      "postedAt" => $row[7],
    );

		$bottomPostedAt = $row[7];
  }

  $rows[$counter++] = array(
    "bottomPostedAt" => $bottomPostedAt,
  );

  echo json_encode($rows);

	$pdo = null;
?>
