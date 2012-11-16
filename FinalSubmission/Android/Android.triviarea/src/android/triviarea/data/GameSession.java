package android.triviarea.data;


import java.util.ArrayList;
import java.util.List;
import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;

import android.content.Context;
import android.triviarea.main.R;
import android.triviarea.utility.Internet;
import android.util.Log;


/**
 * 
 * @author Chad, Sam, Neeraj
 * 
 * Holds all the information for the current game session
 * GameSession is a singleton class (can have only one instance) 
 * since multiple game sessions should not be created and this also
 * allows for data sharing between activities
 * 
 */
public class GameSession
{		
	private Question[] question;
	private Long cumulativeScore;
	private int numOfRounds;
	private int questionSetID;
	private String playCategory;
	private String leaderboardCategory;
	private String leaderboardUserString;
	private String leaderboardScoreString;
	private static String LEADERBOARD_URL;
	private volatile static GameSession instance = null;
	
	
	/**
	 * Private constructor to be called only by the getInstance method 
	 * @param application context
	 */
	private GameSession(Context context) 
	{	
		cumulativeScore = 0L;
		LEADERBOARD_URL = context.getResources().getString(R.string.leaderboard_url);
	}
	
	public static GameSession getInstance()
	{
		return instance;
	}
	
	/**
	 * Returns the instance associated with this class if it exists
	 * Otherwise creates a new one by calling the private constructor
	 * @param application context
	 * @return GameSession instance
	 */
	public static GameSession setInstance(Context context) 
	{
		if (instance == null) {
			instance = new GameSession(context);
		}
		return instance;
	}
	
	/**
	 * Downloads the JSon from the URL 
	 * @param gameSessionURL
	 * @return the JSon file string
	 * @throws BadURLException if can't connect to server
	 */
	public String retrieveJsonFromURL(String gameSessionURL)
	{ 
		return Internet.getHTMLFromUrl(gameSessionURL);
	}

	/**
	 * Sets up the current game session based on the JSon file
	 * @param jsonFile
	 * @return true on success
	 */
	public boolean parseJSON(String jsonFile)
	{
		int countIndex = 0;
		
		countIndex = parseCategory(jsonFile, countIndex);		
		countIndex = calculateNumberOfQuestions(jsonFile, 
				countIndex);
		parseQuestionsAndAnswers(jsonFile, countIndex);
		return true;
	}

	/**
	 * Parses json for question and answers for game session.
	 * @param jsonFile
	 * @param countIndex
	 * @return none
	 */
	private void parseQuestionsAndAnswers(String jsonFile, int countIndex) {
		int endStrIndex;
		question = new Question[numOfRounds];
		String [] wrong;
		wrong = new String[3];
		for(int qIndex = 0; qIndex < numOfRounds; qIndex++){
			question[qIndex] = new Question();
			// Grab Question
			countIndex = jsonFile.indexOf("\":{\"question\":\"", countIndex);
			countIndex = countIndex + 15;
			endStrIndex = jsonFile.indexOf("\",\"", countIndex);
			question[qIndex].setQuestionText(jsonFile.substring(countIndex, endStrIndex));
			
			// Grab Correct Answer
			countIndex = endStrIndex + 16;
			endStrIndex = jsonFile.indexOf("\",\"", countIndex);
			question[qIndex].setCorrectAnswer(jsonFile.substring(countIndex, endStrIndex));

			Log.v("GS", "Grabbing wrong answers");
			//Grab wrong answers
			for(int i = 0; i < 3; i++)
			{
				String parsefor = (i==2)? "\"}" : "\",\"";
				countIndex = endStrIndex + 12;				
				endStrIndex = jsonFile.indexOf(parsefor, countIndex);
				wrong[i] = jsonFile.substring(countIndex, endStrIndex);

			}
			Log.v("GS", "Done Grabbing wrong answers");

			question[qIndex].setWrongAnswers(wrong[0], wrong[1], wrong[2]);	
			Log.v("GS", "Done storing wrong answers");

		}
	}

	/**
	 * Parses json and calculates number of question
	 * @param jsonFile
	 * @param countIndex
	 * @return countIndex
	 */
	private int calculateNumberOfQuestions(String jsonFile, int countIndex) {
		int countBreak = 0;
		
		// Determine number of question
		while(countIndex > 0){
			// Each question in the JSON file contains 4 instances of (",")
			countIndex = jsonFile.indexOf("\",\"", countIndex);
			if(countIndex > 0)
				countBreak++;	
			countIndex++;
		}
		numOfRounds = countBreak / 4;
		return countIndex;
	}

	/**
	 * Parses json for category.
	 * @param jsonFile
	 * @param countIndex
	 * @return countIndex
	 */
	private int parseCategory(String jsonFile, int countIndex) {
		int endStrIndex;
		// Determine category
		countIndex = jsonFile.indexOf("category", countIndex);
		endStrIndex = jsonFile.indexOf("\",\"", countIndex);
		countIndex = countIndex + 11;	
		playCategory = jsonFile.substring(countIndex, endStrIndex);
		return countIndex;
	}
	
	/**
	 * Retrieves the global leaderboard as a json string from the server	
	 * @param category of interest
	 * @return true on success
	 */
	public boolean requestLeaderboard(String category) {
		
		List<NameValuePair> params = new ArrayList<NameValuePair>();
		params.add(new BasicNameValuePair("category", category));
	
		parseLeaderboard(Internet.Post(LEADERBOARD_URL, params));
		
		if(leaderboardScoreString == null || leaderboardUserString == null)
			return false;
		
		return true;
	}
	
	/**
	 * parseLeaderboard parses the leaderboard json received from the server
	 * @param jsonFile is a file containing usernames and respective scores
	 */
	public void parseLeaderboard(String jsonFile){
		leaderboardUserString = parseLeaderboardUsers(jsonFile);
		leaderboardScoreString = parseLeaderboardScores(jsonFile);
	}
	
	/**
	 * parseLeaderboardUsers pulls usernames out of the json
	 * @param jsonFile
	 * @return String of usernames separated by a newline
	 */
	private String parseLeaderboardUsers(String jsonFile){
		String userString = "";
		int lastIndex = 0;
		int firstIndex = 0;
		
		for(int i = 0; i < 5; i++){
			firstIndex = jsonFile.indexOf("user", lastIndex);
			firstIndex = jsonFile.indexOf("\":\"", firstIndex) + 3;
			lastIndex = jsonFile.indexOf("\",\"", firstIndex);
			
			userString = userString + jsonFile.substring(firstIndex, lastIndex);
			userString = userString + "\n";
		}
		
		return userString;
	}
	
	/**
	 * parseLeaderboardScores pulls scores out of the json
	 * @param jsonFile
	 * @return String of scores separated by a newline
	 */
	private String parseLeaderboardScores(String jsonFile){
		String scoreString = "";
		int lastIndex = 0;
		int firstIndex = 0;
		
		for(int i = 0; i < 4; i++){
			firstIndex = jsonFile.indexOf("score", lastIndex);
			firstIndex = jsonFile.indexOf("\":\"", firstIndex) + 3;
			lastIndex = jsonFile.indexOf("\",\"", firstIndex);
			
			scoreString = scoreString + jsonFile.substring(firstIndex, lastIndex);
			scoreString = scoreString + "\n";
		}
		firstIndex = jsonFile.indexOf("score", lastIndex);
		firstIndex = jsonFile.indexOf("\":\"", firstIndex) + 3;
		lastIndex = jsonFile.indexOf("\"}", firstIndex);
		scoreString = scoreString + jsonFile.substring(firstIndex, lastIndex) + "\n";
		
		return scoreString;
	}
	
	//Getters and setters ---------------------------
	public String getLeaderboardUserString() {
		return leaderboardUserString;
	}

	public String getLeaderboardScoreString() {
		return leaderboardScoreString;
	}

	public Long getSessionScore() {
		return cumulativeScore;
	}

	public void setSessionScore(long l) {
		this.cumulativeScore = l;
	}

	public Question[] getQuestion() {
		return question;
	}
	
	public int getNumOfRounds() {
		return numOfRounds;
	}
	
	public String getPlayCategory() {
		return this.playCategory;
	}
	
	public void setPlayCategory(String category) {
		this.playCategory = category;
	}
	
	public String getLeaderboardCategory() {
		return leaderboardCategory;
	}

	public void setLeaderboardCategory(String leaderboardCategory) {
		this.leaderboardCategory = leaderboardCategory;
	}

	public int getQuestionSetID() {
		return questionSetID;
	}
	
	public void setLeaderboard(String myFriends, String friendsScores) {
		leaderboardUserString = myFriends;
		leaderboardScoreString = friendsScores;
	}

}
