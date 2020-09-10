<?php
  include "globalFunctions.php";
  include "/var/www/inc/dbinfo.inc";
  $conn = mysqli_connect(DB_SERVER, DB_USERNAME, DB_PASSWORD, DB_DATABASE);

  /*for ($x = 0; $x < 10000; $x++) {
		$intro = "Introduction here.";
	  $query = "insert into users (username, password, gender, birthday, country, interests, otherInterests, level, intro, gitHub, linkedIn, lastVisit, lastUpdate, accountCreation, lastNewChat) values (".$x.", LEFT(UUID(), 10), 2, \"2000-01-01\", 30, \"&C&&C++&\", \"\", 1, ?, LEFT(UUID(), 20), \"\", date_add(\"1000-01-01\", INTERVAL ".$x." DAY), date_sub(\"1000-01-01\", INTERVAL ".$x." DAY), current_timestamp, current_timestamp);";
	  $stmt = $conn->prepare($query);
	  $stmt->bind_param("s", $intro);
	  $stmt->execute();
	}*/

	/*$intro = "👋 Hi, I’m Sam!\nI’m a beginner w/ Python, Swift, and Flutter but love working on projects, ui/ux, and the tech startup scene.\n\nCo-founder @ Rant\nCheck it out below\nhttps://www.joinrant.com/";
	$username = "Sam Mendel";

  $query = "update users set intro=? where username=?;";
  $stmt = $conn->prepare($query);
  $stmt->bind_param("ss", $intro, $username);
  $stmt->execute();*/

	//echo "success";
?>
