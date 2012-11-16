<?php
    require_once('classes/QuestionSet.php');
    require_once('classes/User.php');

    $category = trim($_POST['category']);
    $userID = trim($_POST['userID']);
    $u = new User($userID, '', '', '');
    $qs = new QuestionSet($category);

    // generate a random question set and return it as a json string
    echo $qs->toJsonString();

    // mark that user has now played the category
    $u->markCategoryPlayed($category);
?>
