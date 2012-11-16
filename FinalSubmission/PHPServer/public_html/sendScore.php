<?php
    require_once('classes/Leaderboard.php');
    require_once('classes/User.php');

    extract($_POST);
    $l = new Leaderboard($category);
    $u = new User($userID, '','','');

    // call function to insert the new score into the leaderboard
    // if the player has scored high enough to place
    $l->insertScore($userID, $score);
    $u->recordScore($category, $score);
?>
