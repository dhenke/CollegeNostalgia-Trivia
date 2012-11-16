<?php
/*
This page is called when the user selects register. This will take input from
the app (either iPhone or Android) and will input into the SQL database the 
inputed information.
*/

    require_once('classes/User.php');
    
    extract($_POST);
    $u = new User(0, mysql_real_escape_string($username), mysql_real_escape_string($password), mysql_real_escape_string($email));
    echo $u->register();

?>
