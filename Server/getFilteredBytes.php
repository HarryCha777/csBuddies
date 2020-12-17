<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $pdo = new PDO("pgsql:host=".HOST.";port=".PORT.";dbname=".DATABASE.";user=".USERNAME.";password=".PASSWORD);

  $myId = $_POST["myId"];
  $sort = $_POST["sort"]; // 0 = new, 1 = trendingScore, 2 = weekly top
  $time = $_POST["time"]; // 0 = week, 1 = month, 2 = all time
  $bottomPostTime = $_POST["bottomPostTime"];
  $bottomTrendingScore = $_POST["bottomTrendingScore"];
  $bottomLikes = $_POST["bottomLikes"];

	if (empty($myId)) {
		$myId = $emptyUuid;
	}

	$isValid =
		isValidInt($sort, 0, 2) &&
		isValidInt($time, 0, 2) &&
		//isValidDate($bottomPostTime, True) &&
		isValidInt($bottomTrendingScore, 0, 30000) &&
		isValidInt($bottomLikes, 0, 30000);
	if (!$isValid) {
  	$pdo = null;
		die("Invalid");
	}

  $query = "select account.user_id, account.username, to_char(account.last_visit_time, 'yyyy-mm-dd hh24:mi:ss.ms'), byte.byte_id, byte.content, byte.likes, to_char(byte.post_time, 'yyyy-mm-dd hh24:mi:ss.ms'), case when byte_like.user_id = ? then true else false end from byte left join byte_like on byte.byte_id = byte_like.byte_id and byte_like.is_liked = true and byte_like.user_id = ? left join account on byte.user_id = account.user_id where byte.is_invisible = false and byte.is_deleted = false ";
	$paramsArray = array($myId, $myId);

	if ($sort == 0) {
		$query .= "and byte.post_time < ? order by byte.post_time desc limit 20;";
  	array_push($paramsArray, $bottomPostTime);
	} else if ($sort == 1) {
		# 1606780800 is unix timestamp for 2020-12-01, and 86400 is number of seconds in a day.
		$trendingScoreSql = "round(cast(greatest(log(10, greatest(byte.likes, 1)), 1) + (extract(epoch from byte.post_time) - 1606780800) / 86400 as numeric), 3)";
		$query .= "and ((".$trendingScoreSql." = ? and byte.post_time < ?) or (".$trendingScoreSql." < ?)) order by ".$trendingScoreSql." desc, byte.post_time desc limit 20;";
  	array_push($paramsArray, $bottomTrendingScore, $bottomPostTime, $bottomTrendingScore);
	} else {
		$query .= "and ((byte.likes = ? and byte.post_time < ?) or (byte.likes < ?)) ";
  	array_push($paramsArray, $bottomLikes, $bottomPostTime, $bottomLikes);

		if ($time == 0) {
			$query .= "and byte.post_time > current_date - interval '7 days' ";
		} else if ($time == 1) {
			$query .= "and byte.post_time > current_date - interval '30 days' ";
		}
		$query .= "order by byte.likes desc, byte.post_time desc limit 20;";
	}

  $stmt = $pdo->prepare($query);
  $stmt->execute($paramsArray);

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

		$bottomPostTime = $row[6];
		# 1606780800 is unix timestamp for 2020-12-01, and 86400 is number of seconds in a day.
		$trendingScorePhp = round(max(log10($row[5]), 1) + (strtotime($row[6]) - 1606780800) / 86400, 3);
		$bottomTrendingScore = $trendingScorePhp;
		$bottomLikes = $row[5];
  }

  $rows[$counter++] = array(
    "bottomPostTime" => $bottomPostTime,
    "bottomTrendingScore" => $bottomTrendingScore,
    "bottomLikes" => intval($bottomLikes),
  );

  echo json_encode($rows);

	$pdo = null;
?>

