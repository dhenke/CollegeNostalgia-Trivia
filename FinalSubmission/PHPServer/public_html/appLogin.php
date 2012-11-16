<?php
    require_once('classes/User.php');

    /* takes the username and password
       returns the userID if name and pw check out
       otherwise returns -1 indicating an error
    */
    $username = trim($_POST['username']);
    $password = trim($_POST['password']);
    $u = new User(0, $username, $password, '');
    echo $u->login();
?>
