<?php
    require_once('classes/Leaderboard.php');

    // takes the category and returns the leaderboard for specified
    // category as a json string
    //  please see exampleLeaderboardJSON.php for an example
    $category = trim($_POST['category']);
    $l = new Leaderboard($category);
    echo $l->getLeaderboard();
?>
