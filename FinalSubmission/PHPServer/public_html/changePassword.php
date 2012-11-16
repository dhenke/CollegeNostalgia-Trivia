<?php
    require_once('classes/User.php');

    extract($_POST);
    // reset the user's password if they forgot it
    if ($request == 'reset') {
        $u = new User('', $username, '', $email);
        echo $u->resetPassword();
    }
    // changes user's password to given new one
    if ($request == 'change') {
        $u = new User($userID, '', $password, '');
        echo $u->changePassword($newPassword);
    }
?>
