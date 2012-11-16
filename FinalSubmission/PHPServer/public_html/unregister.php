<?php
    require_once('classes/User.php');

    // removes the specified user from the database
    extract($_POST);
    $u = new User($userID, $username, '', $email);
    echo $u->unregister();
?>
