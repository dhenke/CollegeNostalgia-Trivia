<?php
    require_once('openDB.php');
    /*
            Class: User
       This class is for anything related to the user. It contains all of the code for:
       Logging in, Registering, Getting Categories not yet played, in addition to all things
       related to the password and friends list.

            Class Variables:
                userId-     integer containing the user's userID.
                username-   string containing the user specified username
                password-   md5 encrypted string containing the user's password
                email-      string containing the user's inputted email address
                friendsList-an array containing the user's friends.
     */
    class User {

        var $userID, $username, $password, $email, $friendsList;

        function __construct($userID, $username, $password, $email) {
            $this->userID = $userID;
            $this->username = $username;
            $this->password = $password;
            $this->email = $email;
            $this->friendsList = array();
        }

        /* checks if username and password check an entry in database
           @return the userID if match is found, -1 otherwise
        */
        function login() {
            $query = 'select * from users where username = "'.$this->username.'" AND password = "'.$this->password.'" LIMIT 1';
            $returned = mysql_query($query);
            if(mysql_num_rows($returned) == 1) {
                $u = mysql_fetch_assoc($returned);
                return $u['userID'];
            }
            else
                return -1;
        }

        /* Registers the user information into the database
           @return error msg if email or username in use already, else the user id of the new user
        */
        function register() {
            $inUseStr = $this->inUse();
            // okay to insert
            if ($inUseStr == 'success') {
                $query = 'insert into users (username, password, email) values ("'.$this->username.'", "'.$this->password.'", "'.$this->email.'")';
                mysql_query($query);
                $query = 'select userID from users where username = "'.$this->username.'"';
                $result = mysql_fetch_array(mysql_query($query));

                // insert user into the scores table
                $query = 'insert into scores (userID) values ('.$result['userID'].')';
                mysql_query($query);
                return $result['userID'];
            }
            else
                return $inUseStr;
        }

        /* checks if username or email is in use
           @return string indicating if in use or not
        */
        function inUse() {
            $query = "select * from users where username = '".$this->username."' OR email = '".$this->email."' limit 1";
            if (mysql_num_rows(mysql_query($query)) != 0)
                return 'username or email in use';
            else
                return 'success';
        }

        /* - Removes the user from the database
           - Probably won't be used in production (testing purposes only)
           @return msg stating success or not
        */
        function unregister() {
            $query = 'select * from users where userID = '.$this->userID.' AND username = "'.$this->username.'" AND email = "'.$this->email.'" LIMIT 1';
            if (mysql_num_rows(mysql_query($query)) != 1)
                return "cannot unregister";
            $query = 'delete from users where userID = '.$this->userID;
            mysql_query($query);
            $query = 'delete from scores where userID = '.$this->userID;
            mysql_query($query);
            return 'deletion successful';
        }

        /* builds a string containing all the categories user has not
           played yet
           @return the string
        */
        function getCategoriesNotPlayed() {
            $query = 'select * from scores where userID = '.$this->userID.' LIMIT 1';
            $result = mysql_fetch_array(mysql_query($query));

            $catNotPlayed = "";
            $categories = array('Music', 'Television', 'Movies', 'History', 'Sports', 'Geography', 'Literature', 'Science_and_Technology', 'Video_Games');
            for ($i = 1; $i <= count($categories); $i++) {
                $query = 'select * from questions where category = "'.$categories[$i-1].'"';
                $numQuestions = mysql_num_rows(mysql_query(str_replace("_", " ",$query)));
                if ($result[$categories[$i-1]] == -1 && $numQuestions >= 15)
                    $catNotPlayed .= $categories[$i-1].',';
            }
            return str_replace("_", " ", $catNotPlayed);
        }

        /* marks the specified category as played by the user
        */
        function markCategoryPlayed($category) {
            $query = 'update scores set '.$category.'=0 where userID='.$this->userID;
            mysql_query($query);
        }

        /* records the user's score for this category in the scores table
        */
        function recordScore($category, $score) {
            $category = str_replace(" ", "_", $category);
            $query = 'update scores set '.$category.' = '.$score.' where userID = '.$this->userID;
            mysql_query($query);
        }

        /* - changes the user's password to newPassword
           - must verify original pw was correct first
           @return success msg if pw change successful, else error msg
        */
        function changePassword($newPassword) {
            $query = 'select * from users where userID = '.$this->userID.' AND password = "'.$this->password.'" LIMIT 1';
            if (mysql_num_rows(mysql_query($query)) == 1) {
                $query = 'update users set password = "'.$newPassword.'" where userID = '.$this->userID;
                mysql_query($query);
                return 'password changed successfully';
            }
            return 'incorrect original password';
        }

        /**
          - resets the user's password to a random string
          - must verify that given username and email are correct
          @return success or error msg
        */
        function resetPassword() {
            $query = 'select * from users where username = "'.$this->username.'" and email = "'.$this->email.'" LIMIT 1';
            $result = mysql_query($query);
            if (mysql_num_rows($result) == 1) {
                // update user's attributes
                $user = mysql_fetch_array($result);
                $this->userID = $user['userID'];
                $this->password = $user['password'];

                // create new random password to reset it to
                $newpassword = $this->generateRandomPassword();
                $this->sendNewPassword($newpassword);
                $this->changePassword(md5($newpassword));
                return 'password reset';
            }
            return 'could not reset';
        }

        /**
          - generates a random string of 10 alphanumeric characters long
          @return the string
        */
        function generateRandomPassword() {
            $str = "";
            for ($i = 0; $i < 10; $i++) {
                $t = rand(0, 2);
                if ($t == 0)
                    $str = $str.chr(rand(65,90));
                else if ($t == 1)
                    $str = $str.chr(rand(97, 122));
                else
                    $str = $str.chr(rand(48, 57));
            }
            return $str;
        }

        /**
          - sends the new password to the user's email
        */
        function sendNewPassword($newpassword) {
            $subject = 'Triviarea Password Reset';
            $headers = 'From: Admin <aychan3@illinois.edu>'."\r\n";
            $headers .= 'Reply-To: aychan3@illinois.edu'."\r\n";
            $message = 'Your password has been reset to '.$newpassword.'. Please use it to change your password within the application.';
            mail($this->email, $subject, $message, $headers);
        }

        /* - get username corresponding to given userID
           - assumed have a valid userID
           @return username for given userID
        */
        function getFriendName($friendID) {
            $query = 'select username from users where userID = '.$friendID;
            $result = mysql_fetch_array(mysql_query($query));
            return $result['username'];
        }

        /* - adds the friend to user's friend list
           - checks if user is already friends with the person first
           @return success or error msg
        */
        function addFriend($friendID) {
            if (!$this->alreadyFriends($friendID)) {
                $query = 'insert into friends (userID, friendID) values ('.$this->userID.', '.$friendID.')';
                mysql_query($query);
                return 'friend added successfully';
            }
            return 'already friends with user';
        }

        /* - removes friend from user's friend list
           - checks if user is friends with the person first
           @return success or error msg
        */
        function removeFriend($friendID) {
            if ($this->alreadyFriends($friendID)) {
                $query = 'delete from friends where userID = '.$this->userID.' and friendID = '.$friendID;
                mysql_query($query);
                return 'friend removed successfully';
            }
            return "no friend to remove";
        }

        /* checks if user is already friends with friendID
           @return true if already friends, else false
        */
        function alreadyFriends($friendID) {
            $query = 'select * from friends where userID = '.$this->userID.' AND friendID = '.$friendID;
            if (mysql_num_rows(mysql_query($query)) != 0)
                return true;
            return false;
        }

        /* - get the user's friend list and each of the friends'
           scores for each category and return as a json string
           @return json string of user's friends and their scores
        */
        function getFriendsList() {
            $query = 'select friendID from friends where userID = '.$this->userID;
            $result = mysql_query($query);

            $this->friendsList['numFriends'] = mysql_num_rows($result);
            $count = 0;
            while ($r = mysql_fetch_array($result)) {
                $id = $r['friendID'];
                $this->friendsList['friend'.$count] = array();
                $this->friendsList['friend'.$count]['friendName'] = $this->getFriendName($id);

				// get scores for friend
				$query = 'select * from scores where userID = '.$id;
				$res = mysql_query($query);
				$scores = mysql_fetch_array($res);
				for ($i = 1; $i < mysql_num_fields($res); $i++)
                    $this->friendsList['friend'.$count][str_replace("_", " ", mysql_field_name($res, $i))] = $scores[$i] == -1 ? 0 : $scores[$i];
                $count++;
            }
            return json_encode($this->friendsList);
        }

        /* - searches for a userID based on the identifier and request
           - request should be either email or username
           @return userID of matching user or -1 if none is found
        */
        function search($identifier, $request) {
            if ($request == 'username')
                $query = 'select userID from users where username = "'.$identifier.'"';
            else
                $query = 'select userID from users where email = "'.$identifier.'"';
            $result = mysql_query($query);
            if (mysql_num_rows($result) == 1) {
                $result = mysql_fetch_array($result);
                return $result['userID'];
            }
            return -1;
        }
    }
?>
