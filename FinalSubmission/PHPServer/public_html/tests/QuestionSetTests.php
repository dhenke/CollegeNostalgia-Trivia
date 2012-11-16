<?php
	require_once('simpletest/autorun.php');
	require_once('../classes/openDB.php');
	require_once('../classes/QuestionSet.php');

	class QuestionSetTests extends UnitTestCase {

		/**
          - tests that constructor correctly creates object
        */
        function testConstructor() {
			$qs = new QuestionSet('Math');
			$this->assertTrue(empty($qs->jsonArray));
			$this->assertEqual($qs->category, 'Math');
		}

        /**
          - tests that json string is properly formatted with question set
        */
		function testToJsonString() {
			$qs = new QuestionSet('Geography');
			$qs->getQuestions();
            $this->assertEqual(16, count($qs->jsonArray));
            $this->assertEqual('Geography', $qs->jsonArray['category']);
		}
	}
?>
