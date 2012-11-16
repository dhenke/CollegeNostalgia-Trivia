

import android.test.AndroidTestCase;
import android.triviarea.data.GameSession;

public class TestGameSession extends AndroidTestCase 
{
	static GameSession gameSession;
	static String jsonURL;
	static String jsonURLFull;
	static String jsonText;
	protected void setUp() 
	{;
		jsonURL = "http://triviarea.projects.cs.illinois.edu/oldExampleJSON.php";
		jsonURLFull = "http://triviarea.projects.cs.illinois.edu/exampleJSON.php";
		jsonText = "{\"setID\":\"1\",\"category\":\"Math\",\"question1\":{\"question\":\"What is a prime number?\",\"correctAns\":\"2\",\"wrong1\":\"4\",\"wrong2\":\"6\",\"wrong3\":\"8\"},\"question2\":{\"question\":\"What is an even number?\",\"correctAns\":\"2\",\"wrong1\":\"3\",\"wrong2\":\"5\",\"wrong3\":\"7\"},\"question3\":{\"question\":\"What is an odd number?\",\"correctAns\":\"3\",\"wrong1\":\"4\",\"wrong2\":\"6\",\"wrong3\":\"8\"}}";
		GameSession.setInstance(getContext());
		gameSession = GameSession.getInstance();
		
	}
	
	public void testRetrieveJsonFromURL()
	{
		String returnedJson = gameSession.retrieveJsonFromURL(jsonURL);
		assertEquals(returnedJson, jsonText);
	}
	
	/**
	 * We use a known json test similiar to one obtained from a server and 
	 * parse it, making sure gameSession is set up right after parsing
	 */
	public void testParseJson()
	{
		final String question1Text = "What is a prime number?";
		final String question2CorrectAnswer = "2";
		final String question3WrongAnswer3 = "8";
		final String category = "Math";
		final int gSID = 0;
		
		gameSession.parseJSON(jsonText);
		
		//game info
		assertEquals(gameSession.getQuestionSetID(), gSID);
		assertEquals(gameSession.getPlayCategory(), category);
		
		//questions
		assertNotNull(gameSession.getQuestion());
		assertEquals(gameSession.getQuestion()[0].getQuestionText(), question1Text);
		assertEquals(gameSession.getQuestion()[1].getCorrectAnswer(), question2CorrectAnswer);
		assertEquals(gameSession.getQuestion()[2].getWrongAnswer(2), question3WrongAnswer3);	
		assertEquals(gameSession.getNumOfRounds(), 3);
	}
}
