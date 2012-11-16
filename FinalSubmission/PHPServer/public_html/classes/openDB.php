<?php
    /* This file is used to open a connection to the database.
       Include this file at the top of each class page to have access
       to the database.
    */

	$dbhost = "localhost";
	$dbusername = "trivia_superman";
	$dbuserpass = "w-~Ra948Q7vC";
	$dbname = "trivia_base";
	$conn = mysql_connect($dbhost, $dbusername, $dbuserpass);
	$selectDB = mysql_select_db($dbname, $conn);
?>
