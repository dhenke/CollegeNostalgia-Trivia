<?php
    require_once('../classes/openDB.php');

    // reset all users in categoriesPlayed table
    $query = 'update scores set Music=-1, Television=-1, Movies=-1, History=-1, Sports=-1, Geography=-1, Literature=-1, Science_and_Technology=-1, Video_Games=-1';
    mysql_query($query);

    // reset the leaderboards
    $query = 'update setLeaderboards set user1 = 0, score1 = 0, user2 = 0, score2 = 0, user3 = 0, score3 = 0, user4 = 0, score4 = 0, user5 = 0, score5 = 0';
    mysql_query($query);
?>
