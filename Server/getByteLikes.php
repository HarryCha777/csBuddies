<?php
  require "globalFunctions.php";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $token = $_POST["token"];
  $byteId = $_POST["byteId"];
  $bottomLastUpdatedAt = $_POST["bottomLastUpdatedAt"];

	if (empty($myId)) {
		$myId = $emptyUuid;
	}

	$isValid =
		($myId == $emptyUuid || isAuthenticated($myId, $token)) &&
		isExtantByteId($byteId) &&
		isValidTime($bottomLastUpdatedAt);
	if (!$isValid) {
  	$pdo = null;
		die("Invalid");
	}

  $query = "
		select account.user_id,
		       account.username,
		       account.birthday,
		       account.gender,
		       account.country,
		       account.intro,
		       account.last_visited_at,
		       byte_like.last_updated_at
		from   account
		       left join byte_like
		              on account.user_id = byte_like.user_id
		where  (account.banned_at is null or account.user_id = ?)
           and account.deleted_at is null
           and byte_like.is_liked = true
		       and byte_like.byte_id = ?
		       and byte_like.last_updated_at < ?
		order  by byte_like.last_updated_at desc
		limit  20;";
  $stmt = $pdo->prepare($query);
  $stmt->execute(array($myId, $byteId, $bottomLastUpdatedAt));

  $counter = 1; // PHP arrays start from 1
  $rows = array();
  while($row = $stmt->fetch()) {
    $rows[$counter++] = array(
      "buddyId" => $row[0],
      "username" => $row[1],
      "birthday" => $row[2],
      "gender" => $row[3],
      "country" => $row[4],
      "intro" => $row[5],
      "lastVisitedAt" => $row[6],
    );

		$bottomLastUpdatedAt = $row[7];
  }

  $rows[$counter++] = array(
    "bottomLastUpdatedAt" => $bottomLastUpdatedAt,
  );

  echo json_encode($rows);

	$pdo = null;
?>
