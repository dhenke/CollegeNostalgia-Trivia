<?php
	require_once('simpletest/autorun.php');
	require_once('../classes/Leaderboard.php');
	require_once('../classes/openDB.php');

	class LeaderboardTests extends UnitTestCase {

        /**
          - makes sure constructor correctly creates object
        */
		function testConstructor() {
			$board = new Leaderboard("testcategory");
			$this->assertEqual($board->category, "testcategory");
		}

        /**
            - tests to make sure leaderboard JSON is correctly created
        */
        function testGet(){
            $board = new Leaderboard("testcategory");
            $this->assertEqual($board->getLeaderboard, "");
            $board = new Leaderboard("Music");
            $this->assertTrue(strstr($board->getLeaderboard,"Music")!=-1);
        }

        /**
          - inserts 3 high scores into the table and then tests to make sure they were inserted correctly
        */
        function testInsertScore() {
            $board = new Leaderboard("testcategory");
            $query = 'insert into setLeaderboards (category) values ("testcategory")';
            mysql_query($query);

            // insert 3 high scores
            $board->insertScore(1, 100);
            $board->insertScore(2, 90);
            $board->insertScore(3, 95);

            $query = 'select * from setLeaderboards where category = "testcategory"';
            // check 1st through 5th place scores & userIDs
            $result = mysql_fetch_array(mysql_query($query));
            $this->assertEqual($result[1], 1);
            $this->assertEqual($result[2], 100);
            $this->assertEqual($result[3], 3);
            $this->assertEqual($result[4], 95);
            $this->assertEqual($result[5], 2);
            $this->assertEqual($result[6], 90);
            $this->assertEqual($result[7], 0);
            $this->assertEqual($result[8], 0);
            $this->assertEqual($result[9], 0);
            $this->assertEqual($result[10], 0);

            $query = 'delete from setLeaderboards where category = "testcategory"';
            mysql_query($query);
        }

    }

?>
