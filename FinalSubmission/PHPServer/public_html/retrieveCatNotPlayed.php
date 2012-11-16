<?php
    require_once('classes/User.php');

    /* takes the user id and returns a string of categories user
       has not played yet
    */
    $u = new User($_POST['userID'], '', '', '');
    echo $u->getCategoriesNotPlayed();
?>
