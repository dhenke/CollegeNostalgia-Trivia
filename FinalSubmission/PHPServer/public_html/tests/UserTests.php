<?php
	require_once('simpletest/autorun.php');
	require_once('../classes/User.php');
	require_once('../classes/Registration.php');

	class UserTests extends UnitTestCase {
        //This tests whether the username or email have already been taken.
        function testInUse(){
            $case1 = new User(0,"testuser","abcd","abcd");
            $this->assertTrue($case1->inUse()=='username or email in use');
            $case2 = new User(0,"tester","abcd","blah@aol.com");
            $this->assertTrue($case1->inUse()=='username or email in use');
            $case3 = new User(0,"tester","abcd","abcd");
            $this->assertTrue($case3->inUse()=='success');
        }

        //This tests the login capability. It should return the userID on success, and -1 on failure.
        function testLogin(){
            $testuser = new User(0,"testuser", md5("abcd"),"abcd");
            $this->assertEqual($testuser->login(), -1);
            $testuser = new User(0,"testuser", md5("pass123"),"abcd");
            $this->assertEqual($testuser->login(), 1);
        }
        
        //This tests the register function by inserting a test user, and then removing it from the database.
        //It succeeds the first time, and then fails because the userID has now been used.
        function testRegister(){
            $case1 = new User(0,"testCaseUsername","abcdfjdksf","abcd@aol.com");
            $this->assertNotEqual($case1->register(),"username or email in use");//should insert
            $this->assertEqual($case1->register(),"username or email in use");//should not insert
            $result = mysql_fetch_array(mysql_query('select userID from users where username = "testCaseUsername"'));
            $userID = $result['userID'];
            $query = 'delete from users where username = "testCaseUsername"';
            mysql_query($query);
            $query = 'delete from scores where userID = ' .$userID;
            mysql_query($query);
        }

        //This returns the getCategoriesNotPlayed method. It will return the string of categories that have yet
        //to be played.
        function testGetCategoriesNotPlayed() {
            $case1 = new User(0, "trash", "not used", "don't read me");
            $query = 'delete from scores where userID = 0';
            mysql_query($query);
            $query = 'insert into scores (userID) values (0)';
            mysql_query($query);
            $query = "update scores set Music=1, Literature = 1, Science_and_Technology = 1 where userID = 0";
            mysql_query($query);
            $this->assertEqual($case1->getCategoriesNotPlayed(), 'Television,History,Sports,Geography,Video Games,');
            $query = "update scores set Music=-1, Literature = -1, Science_and_Technology = -1 where userID = 0";
            mysql_query($query);
        }

        //This will record the score into the SQL database, and then makes sure 
        //the score is there. It then removes it from the database.
        function testRecordScore() {
            $u = new User(0, '', '', '');
            $u->recordScore('Music', 100);
            $query = 'select Music from scores where userID = 0';
            $result = mysql_fetch_array(mysql_query($query));
            $this->assertEqual($result['Music'], 100);
            $query = 'update scores set Music = -1 where userID = 0';
            mysql_query($query);
        }

        //Tests the changePassword method. Fairly self explainatory. It changes a password.
        function testChangePassword() {
            $u = new User(0, "chgPWUsr", "testPassword", "chgpw@something.com");
            $u->register();
            $query = 'select userID from users where username = "chgPWUsr"';
            $result = mysql_fetch_array(mysql_query($query));
            $u->userID = $result['userID'];
            $u->changePassword('newPassword');
            $query = 'select password from users where username = "chgPWUsr"';
            $result = mysql_fetch_array(mysql_query($query));
            $this->assertEqual($result['password'], 'newPassword');
            $u->unregister();
        }

        //This tests adding and removing a person from that person's friend list. 
        function testAddRemoveFriend() {
            $u = new User(0, "addRemove", "testPassword", "ar@something.com");
            $u->register();
            $query = 'select userID from users where username = "addRemove"';
            $result = mysql_fetch_array(mysql_query($query));
            $u->userID = $result['userID'];
            $u->addFriend(0);
            $query = 'select * from friends where userID = '.$u->userID.' and friendID = 0';
            $this->assertEqual(mysql_num_rows(mysql_query($query)), 1);
            $u->removeFriend(0);
            $query = 'select * from friends where userID = '.$u->userID.' and friendID = 0';
            $this->assertEqual(mysql_num_rows(mysql_query($query)), 0);
            $u->unregister();
        }

        //This checks our premade user and checks whether the friends are there. IT returns the userID
        //on success, and -1 on failure.
        function testSearchFriends() {
            $identifier = 'aychan3';
            $this->assertEqual(User::search($identifier, 'username'), 2);
            $this->assertEqual(User::search($identifier, 'email'), -1);
            $identifier = 'aychan3@illinois.edu';
            $this->assertEqual(User::search($identifier, 'email'), 2);
            $this->assertEqual(User::search($identifier, 'username'), -1);
        }

        //This checks whether getFriendsList returns the correct jsonArray.
        function testGetFriendsList() {
            $u = new User(0, '', '', '');
            $noFriends = $u->getFriendsList();
            $this->assertEqual($noFriends, '{"numFriends":0}');
            $u->addFriend(1);
            $haveFriends = $u->getFriendsList();
            $this->assertEqual($haveFriends, '{"numFriends":1,"friend0":{"friendName":"testuser","Music":0,"Television":0,"Movies":0,"History":0,"Sports":0,"Geography":0,"Literature":0,"Science and Technology":0,"Video Games":0}}');
            $u->removeFriend(1);
        }
	}
?>
