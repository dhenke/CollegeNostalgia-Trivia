<?php
    require_once('openDB.php');

    /** 
        Class: Leaderboard
            This class contains all of the leaderboard information. It has the capability to
            grab the leaderboard of a given category, as well as update the leaderboard on
            the server. Each leaderboard contains 5 users and their corresponding scores.

        Class Variables:
            category:   string containing the category. It can be one of 9 possabilities.
            jsonArray:  this is the jsonArray of the leaderboard.
    */
    class Leaderboard {

        var $category, $jsonArray;

        function __construct($category) {
            $this->category = $category;
            $this->jsonArray = array();
        }

        /**
          - gets the leaderboard for the given category
          - @return json string containing the leaderboard
        */
        function getLeaderboard() {
            $query = 'select * from setLeaderboards where category = "'.$this->category.'" LIMIT 1';
            $result = mysql_fetch_array(mysql_query($query));
            
            $this->jsonArray['category'] = $this->category;

            // retrieve corresponding username for each userID stored
            // before encoding into json string
            for ($i = 1; $i < 10; $i+=2) {
                $query = 'select username from users where userID = '.$result[$i];
                $user = mysql_fetch_array(mysql_query($query));
                $this->jsonArray['user'.(($i+1)/2)] = $user['username'];
                $this->jsonArray['score'.(($i+1)/2)] = $result[$i+1];
            }

            return json_encode($this->jsonArray);
        }

        /**
          - checks to see if given score places the user on the leaderboard
          - if user places, place him and move everyone below him down
          - no return value
        */
        function insertScore($userID, $score) {
            $query = 'select * from setLeaderboards where category = "'.$this->category.'"';
            $result = mysql_fetch_array(mysql_query($query));
            $scores = $this->updateScores($result, $score, $userID);

            // create query to update the leaderboard
            $query = 'update setLeaderboards set ';
            for ($i = 1; $i < 10; $i+=2) {
                $query .= 'user'.(($i+1)/2).' = '.$scores[$i].', ';
                $query .= 'score'.(($i+1)/2).' = '.$scores[$i+1];
                if ($i < 8)
                    $query .= ', ';
                else
                    $query .= ' ';
            }
            $query .= 'where category = "'.$result[0].'"';
            mysql_query($query);
        }

        /**
          - creates a newly updated leaderboard with possibly new high
            score inserted
          @return array holding the updated leaderboard
        */
        function updateScores($result, $score, $userID) {
            $scores = array();
            // populate the scores array with 1st through 5th place
            // scores array is used down below to create update query
            $insertedAlready = false;
            for ($i = 1; $i < 10; $i+=2) {
                // user's score is higher than current and it has not been
                // inserted in a higher spot already
                if ($score > $result[$i+1] && !$insertedAlready) {
                    $scores[$i] = $userID;
                    $scores[$i+1] = $score;
                    $insertedAlready = true;
                }
                // user's score is not higher than current so current spot
                // remains unchanged
                else if (!$insertedAlready) {
                    $scores[$i] = $result[$i];
                    $scores[$i+1] = $result[$i+1];
                }
                // user's score is higher than current but it already
                // placed in a higher slot, so we have to shift all scores
                // below it down by one. this grabs the score one
                // position above it in the original leaderboard and places
                // it in this position.
                else {
                    $scores[$i] = $result[$i-2];
                    $scores[$i+1] = $result[$i-1];
                }
            }
            return $scores;
        }
    }
?>
