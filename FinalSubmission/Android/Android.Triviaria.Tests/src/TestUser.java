import junit.framework.TestCase;

import android.app.Application;
import android.test.AndroidTestCase;
import android.triviarea.data.User;
public class TestUser extends AndroidTestCase  {

	static User user;
	static String password;
	static String username;
	static String email;
	protected void setUp() throws Exception {
		super.setUp();
		password = "ANDROIDTESTPW";
		username = "ANDROIDTESTUSERNAME";
		email = "android@test.em";
		user = User.setInstance(getContext());
		user.setUsername(username);
		user.setPassword(password);
		user.setEmail(email);
		user.unregister();
		
	}
	
	/**
	 * register a user, should succeed. Try to register the same user.
	 * We can't have two users with the same information on the server
	 */
	public void testRegister()
	{
		assertTrue(user.register(null));
		assertFalse(user.register(null)); //double register should fail
		user.unregister();
	}
	
	/**
	 * Testing connecting to the server and verifying credentials. 
	 * We try regisetering with a wrong password, username, and email at diff
	 * times. They should all fail.
	 */
	public void testLogin()
	{
		user.register(null);
		assertTrue(user.login(null));
		user.setPassword("newpassword"); //diff password -- Fail
		assertFalse(user.login(null));
		user.setPassword(password); //good credentials -- Succeed
		assertTrue(user.login(null)); 
		user.setUsername("newUserNameXXXXXXXXXX");//diff user name -- Fail
		assertFalse(user.login(null));
		user.setUsername(username); //good credentials -- Succeed
		assertTrue(user.login(null));
		user.unregister();
	}
	/**
	 * Tests the regular expression checker for usernames.
	 */
	public void testSetUsername()
	{
		assertFalse(user.setUsername("hi+"));
		assertFalse(user.setUsername("."));
		assertFalse(user.setUsername(" "));
		assertTrue(user.setUsername("Cha_d94_"));
	}
	
	/**
	 * Tests the regular expression checker for emails.
	 */
	public void testSetEmail()
	{
		assertFalse(user.setEmail("NoAndSign.com"));
		assertFalse(user.setEmail("NoDot@anywhere"));
		assertFalse(user.setEmail("invalidCharacter!@ohNoes.com"));
		assertFalse(user.setEmail("ohNoes@invalidCharacter!.com"));
		assertFalse(user.setEmail("OhNoes@invalidCharacter.com!"));
		assertTrue(user.setEmail("_this+Lo.oks-Go.od%@just.like-your_mom.cOm"));
	}
	/**
	 * Tests the regular expression checker for passwords.
	 */
	public void testSetPassword()
	{
		assertFalse(user.setPassword(" "));
		assertFalse(user.setPassword(""));
		assertFalse(user.setPassword("asdggf\n"));
		assertFalse(user.setPassword("asdf"));
		assertTrue(user.setPassword("asdiiaojdon234n234n"));
	}

}
