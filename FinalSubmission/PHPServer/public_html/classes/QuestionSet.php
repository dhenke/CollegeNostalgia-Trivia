<?php
	/**
	  This class creates and holds the question sets.
	*/
	require_once('openDB.php');
    /**
        Class: QuestionSet
            This is a group of Questions which is used to send to users for game play.
            Each QuestionSet contains 15 questions. 
        Class Variables:
            category:   this is a string containing the category. Note this can only be one of 9 possibilites.
            jsonArray:  this is the array of questions converted into a jsonArray.
      */
	class QuestionSet {

		var $category;
		var $jsonArray;

		function QuestionSet ($category) {
			$this->category = $category;
			$this->jsonArray = array();
		}

        /**
          get 15 random questions from this category and build a json object
        */
        function getQuestions() {
            // get all questions in this category
            $query = 'select question, correctAns, wrong1, wrong2, wrong3 from questions where category = "'.$this->category.'"';
            $queryResult = mysql_query($query);
            $numRows = mysql_num_rows($queryResult);
            
            // choose 15 of the questions at random
            $randomQuestions = array();
            $counter = 0;
            while ($counter < 15) {
                $r = rand(0, $numRows-1);
                if (!isset($randomQuestions[$r])) {
                    $randomQuestions[$r] = $r;
                    $counter++;
                }
            }

            // builds the json object
            $this->jsonArray['category'] = $this->category;
            $counter = 0;
            foreach ($randomQuestions as $r) {
                mysql_data_seek($queryResult, $r);
                $question = mysql_fetch_assoc($queryResult);
                $this->jsonArray['question'.($counter+1)] = $question;
                $counter++;
            }
        }

        /**
		   Converts the JSON object into a JSON string and returns it.
		*/
		function toJsonString() {
            if (empty($this->jsonArray))
                $this->getQuestions();
			return json_encode($this->jsonArray);
		}
    }
?>
