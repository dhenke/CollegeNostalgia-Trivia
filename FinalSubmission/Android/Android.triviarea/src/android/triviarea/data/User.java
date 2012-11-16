package android.triviarea.data;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Hashtable;
import java.util.List;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import android.content.ContextWrapper;
import android.triviarea.main.R;
import android.triviarea.utility.Internet;
import android.util.Log;

/**
 * This class store necessary information about the person playing the game
 * and provides functions for various user operations
 * 
 * @author Chad, Sam, Neeraj
 * 
 */
public class User {
	
	private int cumulativeScore;
	private String userID;
	private String password;
	private String email;
	private String username;
	private String myFriends;
	private final static String TAG = "User";
	private static String INFO_FILE_NAME;
	private static String LOGIN_URL; 
	private static String REGISTER_URL;
	private static String FRIEND_URL;
	private static String UNREGISTER_URL; 
	private static String CATEGORIES_URL; 
	private Context context;
	
	private ArrayList<String> friends = null;
	private String[] availableCategories;
	private String[] allCategories = {"Music", "Television", "Movies", "History", "Sports", "Geography",
									  "Literature", "Science and Technology", "Video Games"};
	
	private Hashtable<String, String> friendsScores = new Hashtable<String, String>();
	private static User instance = null;

	/**
	 * Returns the instance associated with this class if it exists Otherwise
	 * creates a new one by calling the private constructor.
	 * 
	 * @param Context - set as null if you don't want to load or save information
	 * @return GameSession instance
	 */
	public static User setInstance(Context context) {
		if (instance == null) {
			instance = new User(context);
		}
		return instance;
	}
	
	public static User getInstance() {
		return setInstance(null);
	}
	
	private User(Context context)
	{
		this.context = context;
		INFO_FILE_NAME = context.getResources().getString(R.string.user_file);
		LOGIN_URL = context.getResources().getString(R.string.user_login_url); 
		REGISTER_URL = context.getResources().getString(R.string.user_register_url); 
		FRIEND_URL = context.getResources().getString(R.string.user_friend_url); 
		UNREGISTER_URL = context.getResources().getString(R.string.user_unregister_url);  
		CATEGORIES_URL = context.getResources().getString(R.string.categories_url);  
		loadInfo(context);		
	}
	
	/**
	 * Saves the users username and password to the phone separated by ';'
	 * @param save context
	 */
	private void saveInfo(Context save)
	{
		Log.v(TAG, "Saving info");
		if(save == null)
			return;
		if(password != null && username != null)
		{
			try
			{
				Log.v(TAG, "Saving user information");
				FileOutputStream fos = save.openFileOutput(INFO_FILE_NAME, ContextWrapper.MODE_PRIVATE);
				fos.write((username + ";" + password + ";").getBytes());
				Log.v(TAG, "Done saving");
			}
			catch (FileNotFoundException e){Log.e(TAG, e.toString()); } 
			catch (IOException e){Log.v(TAG, e.toString());	}
		}
		Log.v(TAG, "Done Saving info");
	}
	
	/**
	 * loads the user info stored to the phone
	 * @param load context
	 */
	private void loadInfo(Context load)
	{
		Log.v(TAG, "Loading info");
		if(load == null)
			return;
		try
		{
			FileInputStream fis = load.openFileInput(User.INFO_FILE_NAME);
			String username;
			String password;
			byte[] buffer = new byte[256];
			fis.read(buffer);
			fis.close();
			//grabbing stored username and password
			Log.v(TAG, "Parsing saved info");
			String [] result = (new String(buffer)).split(";");
			if(result.length < 2)
			{
				Log.v(TAG, "file info saved incorrectly");
				return;
			}
			Log.v(TAG, "Info parsed");
			username = result[0];
			password = result[1];
			Log.v(TAG, "username gotten: " + username);
			Log.v(TAG, "password gotten: " + password);
			//set username and password for user and text fields on the screen
			this.setUsername(username);
			this.setPassword(password);	
			Log.v(TAG, "Done Loading info");
		} 
		catch (FileNotFoundException e)
		{
			Log.v(TAG, "no info saved" + e.toString());
			return;
		} catch (IOException e)
		{
			Log.v(TAG, "info saved in wrong format" + e.toString());
			return;
		}		
	}

	/**
	 * Connects to server for login based on this.username and this.password
	 * Sets userID from server and saves user info on success
	 * @return true on success, false otherwise
	 */
	public boolean login(Context context) {
		Log.v(TAG, "loggin in, username : " + username + "password : " + password);
		if(this.password == null || this.username == null)
			return false;

		List<NameValuePair> params = new ArrayList<NameValuePair>();
		params.add(new BasicNameValuePair("username", username));
		params.add(new BasicNameValuePair("password", Internet.convertToMD5(password)));
		
		userID = Internet.Post(LOGIN_URL, params);
		if(userID == null || userID.equals("-1"))
			return false;
		else
		{
			saveInfo(context);
			return true;
		}
	}

	/**
	 * Attempts to register this user to the server. this.username, password, and email must be set
	 * On succesful register, updates userID
	 * @return false if the name is unavailable, true on success
	 */
	public boolean register(Context context)
	{
		Log.v(TAG, "registering username : " + username + "password : " + password);
		if(this.username == null || this.password == null || this.email == null)
			return false;
		String newUserID = null;

		List<NameValuePair> params = new ArrayList<NameValuePair>();
		params.add(new BasicNameValuePair("username", username));
		params.add(new BasicNameValuePair("password", Internet.convertToMD5(password)));
		params.add(new BasicNameValuePair("email", email));
		newUserID = Internet.Post(REGISTER_URL, params);
		Log.v(TAG , "newUserID = " + newUserID);
		if(newUserID == null || newUserID.equals("username or email in use"))
			return false;
		else
		{
			this.userID = newUserID;
			saveInfo(context);
			return true;
		}
	}
	
	/**
	 * Unregisters a user from the server. Testing method.
	 */
	public void unregister()
	{
		List<NameValuePair> params = new ArrayList<NameValuePair>();
		params.add(new BasicNameValuePair("username", username));
		params.add(new BasicNameValuePair("userID", userID));
		params.add(new BasicNameValuePair("email", email));
		Internet.Post(UNREGISTER_URL, params);
	}
	
	/**
	 * contacts server requesting for categories that the user can still play 
	 */
	public void requestAvailableCategories() {
			List<NameValuePair> params = new ArrayList<NameValuePair>();
			params.add(new BasicNameValuePair("userID", userID));
			String postResponse = Internet.Post(CATEGORIES_URL, params);
			availableCategories = postResponse.split(",");
	}
	
	/**
	 * user name can be any string of characters, numbers, and _ with at least
	 * one character
	 * @param username
	 * @return true on success, false otherwise
	 */
	public boolean setUsername(String username) {
		Log.v(TAG, "Setting user name");
		
		if(validateUsername(username)) //if username has only char's [0-9][a-Z][_]
		{
			this.username = username;
			return true;
		}
		else return false;
	}
	
	public boolean validateUsername(String username)
	{
		String usernameRegEX = context.getResources().getString(R.string.user_username_regEX);
		return username != null && username.matches(usernameRegEX);
	}

	/**
	 * Passwords can be any string of non white space characters greater than
	 * or equal to 5
	 * @param password
	 * @return true on success, false otherwise
	 */
	public boolean setPassword(String password) {
		Log.v(TAG, "Setting password");
		if(validatePassword(password))
		{
			this.password = password;
			Log.v(TAG, "password set");
			return true;
		}
		else return false;
	}

	public boolean validatePassword(String password)
	{
		String passwordRegEx = context.getResources().getString(R.string.user_password_regEX);
		return password != null && password.matches(passwordRegEx);
	}

	/**
	 * checks to make sure the format of the email is correct
	 * Sets email if it is
	 * @param email
	 * @return true on success, false otherwise
	 */
	public boolean setEmail(String email)
	{
		Log.v(TAG, "setting email");
		if(validateEmail(email))
		{
			this.email = email;
			return true;
		}
		else return false;
	}

	public boolean validateEmail(String email)
	{
		String emailRegEX = context.getResources().getString(R.string.user_email_regEX);
		return email != null && email.matches(emailRegEX);
	}
		
	/**
	 * This gets and sets the users friends scores for the friends leaderboard 
	 * @return true on success, false otherwise
	 */
	public boolean requestFriendsScores()
	{
		try
		{	
			myFriends = "";
			friendsScores.clear();
			
			String jsonFriendsList = getJsonFriendList();
			JSONObject json = new JSONObject(jsonFriendsList);
			int numFriends = json.getInt("numFriends");
			for(int i = 0; i < numFriends; i++)
			{
				JSONObject friend = json.getJSONObject("friend" + String.valueOf(i));
				myFriends = myFriends + friend.getString("friendName");
				myFriends = myFriends + "\n";
			}
			
			for (int i=0; i<9; i++) 
			{
				String score = "";
				String category = allCategories[i];
				
				for (int j=0; j<numFriends; j++)
				{
					JSONObject friend = json.getJSONObject("friend" + String.valueOf(j));
					score = score + String.valueOf(friend.getInt(category));
					score = score + "\n";
				}
				friendsScores.put(category, score);				
			}
			return true;
		}
		catch(JSONException e)
		{
			Log.e(TAG, e.toString());
			return false;
		}
	}
	
	/**
	 * This gets and sets the users friends list from the server.
	 * @return list of friends
	 */
	public ArrayList<String> getFriends()
	{
		if(friends == null)
		{
			friends = new ArrayList<String>();
			try
			{	
				String jsonFriendsList = getJsonFriendList();
				JSONObject json = new JSONObject(jsonFriendsList);
				int numFriends = json.getInt("numFriends");
				for(int i = 0; i < numFriends; i++)
				{
					JSONObject friend = json.getJSONObject("friend" + String.valueOf(i));
					friends.add(friend.getString("friendName"));
				}
			}
			catch(JSONException e)
			{
				Log.e(TAG, e.toString());
			}
		}
		
		return friends;
	}

	/**
	 * This gets the raw friends list json from the server
	 * @return friends list json
	 */
	public String getJsonFriendList()
	{
		List<NameValuePair> params = new ArrayList<NameValuePair>();
		params.add(new BasicNameValuePair("request", "list"));
		params.add(new BasicNameValuePair("userID", userID));
		String json = Internet.Post(FRIEND_URL, params);
		if(json != null)
			Log.v(TAG, "got json from server" + json);
		return json;
	}

	/**
	 * Allows removal of friends from a list
	 * @param friendsToBeDeleted
	 */
	public void removeFriends(Collection<String> friendsToBeDeleted)
	{
		for(String s : friendsToBeDeleted)
			removeFriend(s);		
	}
	
	/**
	 * Only removes friend if the local friends list has this friend in
	 * its array. Returns true if friend was removed from the local copy
	 * Attempts to remove from server after
	 * @param friend
 	 * @return true on success, false otherwise
	 */
	public boolean removeFriend(String friend)
	{
		if(friends == null || friend == null)
			return false;
		if(friends.contains(friend))
		{
			String friendID = getFriendID(friend);
			if(friendID.equals("-1")) 
				return false;
			List<NameValuePair> params = new ArrayList<NameValuePair>();
			params.add(new BasicNameValuePair("request", "remove"));
			params.add(new BasicNameValuePair("friendID", friendID));
			params.add(new BasicNameValuePair("userID", userID));
			Log.v(TAG, "Posting remove friend request to server");			
			String result = Internet.Post(FRIEND_URL, params);
			if(result.equals("friend removed successfully"))
			{
				friends.remove(friend);
				return true;
			}
		}
		return false;
	}

	/**
	 * only adds friend if the friend is not already on the local friends list
	 * Returns true if the friend was removed from the local copy
	 * @param friendName
	 * @return true on success, false otherwise
	 */
	public boolean addFriend(String friendName)
	{
		if(friendName == null)
			return false;
		getFriends(); //makes sure their friends list isn't null
		if(! friends.contains(friendName))
		{
			String friendID = getFriendID(friendName);
			if(friendID.equals("-1")) 
				return false;
			List<NameValuePair> params = new ArrayList<NameValuePair>();
			params.add(new BasicNameValuePair("request", "add"));
			params.add(new BasicNameValuePair("friendID", friendID));
			params.add(new BasicNameValuePair("userID", userID));
			Log.v(TAG, "Posting add friend request to server for" + friendName + " " + friendID);
			String result = Internet.Post(FRIEND_URL, params);
			Log.v(TAG, result);
			if(result.equals("friend added successfully"))
			{
				Log.v(TAG, "successfull add!");
				friends.add(friendName);
				return true;
			}
		}
		return false;
	}
	
	/**
	 * returns corresponding userID or -1 if friend does not exist
	 * @param friend
	 * @return userID
	 */
	private String getFriendID(String friend)
	{
		List<NameValuePair> params = new ArrayList<NameValuePair>();
		params.add(new BasicNameValuePair("request", "searchUsername"));
		params.add(new BasicNameValuePair("username", friend));
		return Internet.Post(FRIEND_URL, params);
	}
	

	// Getters And Setters

	public String[] getAvailableCategories() {
		if (availableCategories == null)
			requestAvailableCategories();
		return availableCategories;
	}

	public void removeAvailableCategory(String[] playedCategories) {
		this.availableCategories = playedCategories;
	}

	public GameSession getGameSession() {
		return GameSession.getInstance();
	}
	
	public String getUserID() {
		return userID;
	}
	
	public int getCumulativeScore() {
		return cumulativeScore;
	}
	
	public String getPassword()
	{
		return password;
	}
	
	public String getEmail()
	{
		return email;
	}
	
	public String getUsername()
	{
		return username;
	}
	
	public String getMyFriends()
	{
		return myFriends;
	}
	
	public Hashtable<String, String> getFriendsScores()
	{
		return friendsScores;
	}
}
