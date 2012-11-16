<?php
    require_once('classes/User.php');

    extract($_POST);

    // request: searchUsername
    if ($request == 'searchUsername') {
        echo User::search($username, 'username');
    }

    // request: searchEmail
    if ($request == 'searchEmail') {
        echo User::search($email, 'email');
    }

    // request: add
    if ($request == 'add') {
        $u = new User($userID, '', '', '');
        echo $u->addFriend($friendID);
    }

    // request: remove
    if ($request == 'remove') {
        $u = new User($userID, '', '', '');
        echo $u->removeFriend($friendID);
    }

    // request: list
    if ($request == 'list') {
        $u = new User($userID, '', '', '');
        echo $u->getFriendsList();
    }
?>
