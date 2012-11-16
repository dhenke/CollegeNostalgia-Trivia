

import java.util.ArrayList;
import java.util.List;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;

import android.test.AndroidTestCase;
import android.triviarea.utility.Internet;
import android.util.Log;
import junit.framework.TestCase;

public class TestUtilities extends AndroidTestCase 
{

	public void testInternetGetHTMLFromURL()
	{
		String jsonURL = "http://triviarea.projects.cs.illinois.edu/oldExampleJSON.php";
		String jsonText = "{\"setID\":\"1\",\"category\":\"Math\",\"question1\":{\"question\":\"What is a prime number?\",\"correctAns\":\"2\",\"wrong1\":\"4\",\"wrong2\":\"6\",\"wrong3\":\"8\"},\"question2\":{\"question\":\"What is an even number?\",\"correctAns\":\"2\",\"wrong1\":\"3\",\"wrong2\":\"5\",\"wrong3\":\"7\"},\"question3\":{\"question\":\"What is an odd number?\",\"correctAns\":\"3\",\"wrong1\":\"4\",\"wrong2\":\"6\",\"wrong3\":\"8\"}}";
		assertEquals(Internet.getHTMLFromUrl(jsonURL), jsonText);
	}
	/**
	 * We test the post function by registering and unregistering a user. 
	 * We test a successful register and an unsuccesful. Unregister user 
	 * is a method specifically for testing and we do not test it extensively.
	 */
	public void testInternetPost()
	{
		String username = " ";
		String password = "d";
		String email = " ";

		final String RegisterUrl = "http://triviarea.projects.cs.illinois.edu/register.php";
		final String UnregisterUrl = "http://triviarea.projects.cs.illinois.edu/unregister.php";
		String newUserID = null;

		BasicNameValuePair passwordPair = new BasicNameValuePair("password", password);
		List<NameValuePair> params = new ArrayList<NameValuePair>();
		params.add(new BasicNameValuePair("username", username));
		params.add(passwordPair);
		params.add(new BasicNameValuePair("email", email));
		newUserID = Internet.Post(RegisterUrl, params);
		
		//The tests
		String errorMessage = "username or email in use";
		assertNotNull(newUserID);
		assertFalse(newUserID.equals(errorMessage));
		assertEquals(Internet.Post(RegisterUrl, params), errorMessage);
		
		//unregister
		params.remove(passwordPair);
		params.add(new BasicNameValuePair("userID", newUserID));
		Internet.Post(UnregisterUrl, params);
	}

	/**
	 * Makes sure MD5 encoding works and is deterministic
	 */
	public void testInternetConvertToMD5()
	{
		String string = "asjkdhaksjdhasdasd";
		String sameString  = "asjkdhaksjdhasdasd";
		String diffString = "asjkdhaksj1dhasdasd";
		assertTrue((Internet.convertToMD5(string)).equals((Internet.convertToMD5(sameString))));
		assertFalse(Internet.convertToMD5(diffString).equals(Internet.convertToMD5(string)));	
	}
}
