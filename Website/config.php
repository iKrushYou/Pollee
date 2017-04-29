<?php

//database information

// if ($_SERVER['HTTP_HOST'] == 'localhost' || $_SERVER['HTTP_HOST'] == '192.168.40.133' || $_SERVER['HTTP_HOST'] == '10.6.3.36') {
// 	$db_name = "BlueLights";
// 	$db_host = "127.0.0.1";
// 	$db_user = "root";
// 	$db_pass = "";

// } else {
	$db_name = "blueligh_pollee";
	$db_host = "bluelightsapp.com";
	$db_user = "blueligh_pollee";
	$db_pass = "Password123!";
// }

$pdo = new PDO("mysql:dbname=".$db_name.";host=".$db_host, $db_user, $db_pass);

function getDB() {
	global $db_name, $db_host, $db_user, $db_pass;
	
	$pdo = new PDO("mysql:dbname=".$db_name.";host=".$db_host, $db_user, $db_pass);

	return $pdo;
}

//columns to select when querying a user
$user_cols = 'id, created_at, updated_at, email, admin, active, first_name, last_name, phone, sound, departments, channels';

?>