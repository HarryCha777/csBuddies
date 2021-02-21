<?php
require "globalFunctions.php";
$pdo = new PDO("pgsql:host=" . HOST . ";port=" . PORT . ";dbname=" . DATABASE . ";user=".USERNAME . ";password=" . PASSWORD);

$myId = $_POST["myId"];
$token = $_POST["token"];
$gender = (int) $_POST["gender"]; // -1 = all, 0 = male, 1 = female, 2 = other
$minAge = (int) $_POST["minAge"];
$maxAge = (int) $_POST["maxAge"];
$country = (int) $_POST["country"]; // -1 = all, 0 = Afghanistan, ... 196 = Zimbabwe
$sort = (int) $_POST["sort"]; // 0 = active, 1 = new
$interests = $_POST["interests"]; // interests example: "&C++&&Python&&SwiftUI&"
$bottomLastVisitedAt = $_POST["bottomLastVisitedAt"];
$bottomSignedUpAt = $_POST["bottomSignedUpAt"];

if (empty($myId)) {
    $myId = $emptyUuid;
}

$query = "insert into time_format_2 (user_id, bottom_last_visited_at_string) values (?, ?);";
$stmt = $pdo->prepare($query);
$stmt->execute(array($myId, $bottomLastVisitedAt));

$isValid =
    ($myId === $emptyUuid || isAuthenticated($myId, $token)) &&
    isValidInt($gender, -1, 2) &&
    isValidInt($minAge, 13, 130) &&
    isValidInt($maxAge, $minAge, 130) &&
    isValidInt($country, -1, 196) &&
    isValidInterests($interests) &&
    isValidInt($sort, 0, 1) &&
    isValidTime($bottomLastVisitedAt) &&
    isValidTime($bottomSignedUpAt);
if (!$isValid) {
    $pdo = null;
    die("Invalid");
}

$query = "select user_id, username, birthday, gender, country, intro, last_visited_at, signed_up_at from account where not user_id = ? and banned_at is null and disabled_at is null and deleted_at is null ";
$paramsArray = array($myId);

if ($gender !== -1) {
    $query .= "and gender = ? ";
    array_push($paramsArray, $gender);
}

if ($minAge !== 13 || $maxAge !== 130) {
    $maxAge += 1;
    $minDate = date("Y-m-d", strtotime("-{$maxAge} years"));
    $maxDate = date("Y-m-d", strtotime("-{$minAge} years"));
    $query .= "and birthday between ? and ? ";
    array_push($paramsArray, $minDate, $maxDate);
}

if ($country !== -1) {
    $query .= "and country = ? ";
    array_push($paramsArray, $country);
}

// Select buddies with OR interests.
if (strlen($interests)) {
    $query .= "and (false ";

    $interests = substr($interests, 1, -1);
    $interestsArray = explode("&&", $interests);
    foreach ($interestsArray as $interest) {
        $query .= "or interests like ? ";
        array_push($paramsArray, "%&{$interest}&%");
    }

    $query .= ") ";
}

// Select buddies with AND interests.
/*if (strlen($interests)) {
$query .= "and interests like ? ";
$likeQuery = "%";

$interests = substr($interests, 1, -1);
$interestsArray = explode("&&", $interests);
foreach ($interestsArray as $interest) {
$likeQuery .= "&{$interest}&%";
}
array_push($paramsArray, $likeQuery);
}*/

if ($sort === 0) {
    # Hide new users who made their accounts up to 1 day ago
    # in order to prevent new users from cluttering active users sort and prevent mass spam of new user account.
    //$query .= "and last_visited_at < ? and signed_up_at < current_date - interval '1 days' order by last_visited_at desc limit 20;";
    $query .= "and last_visited_at < ? order by last_visited_at desc limit 20;";
    array_push($paramsArray, $bottomLastVisitedAt);
} else {
    $query .= "and signed_up_at < ? order by signed_up_at desc limit 20;";
    array_push($paramsArray, $bottomSignedUpAt);
}

$stmt = $pdo->prepare($query);
$stmt->execute($paramsArray);

$counter = 1; // PHP arrays start from 1
$rows = array();
while ($row = $stmt->fetch()) {
    $rows[$counter++] = array(
        "buddyId" => $row[0],
        "username" => $row[1],
        "birthday" => $row[2],
        "gender" => $row[3],
        "country" => $row[4],
        "intro" => $row[5],
        "lastVisitedAt" => $row[6],
    );

    $bottomLastVisitedAt = $row[6];
    $bottomSignedUpAt = $row[7];
}

$rows[$counter++] = array(
    "bottomLastVisitedAt" => $bottomLastVisitedAt,
    "bottomSignedUpAt" => $bottomSignedUpAt,
);

echo json_encode($rows);

$pdo = null;

/*echo "QUERY: {$query}\n";
echo "ARRAY: ";
print_r($paramsArray);*/
