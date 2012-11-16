package android.triviarea.threads;

import java.util.ArrayList;
import java.util.List;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;

import android.triviarea.data.GameSession;
import android.triviarea.data.User;
import android.triviarea.main.LoadQuestionsScreen;
import android.triviarea.main.MainScreen;
import android.triviarea.utility.Internet;

/**
 * This thread runs as a background service and retrieves a question set from the server
 */
public class QuestionsThread extends Thread {

	private static final String QUESTIONS_URL = "http://triviarea.projects.cs.illinois.edu/retrieveQuestionSet.php";
	
	private MainScreen mainScreen;

	public QuestionsThread() {
		super();
	}

	@Override
	public void run() {

		try {
			GameSession gameSession = GameSession.getInstance();
			User user = User.setInstance(mainScreen);
			String chosenCategory = gameSession.getPlayCategory();
			String jsonFile = null;

			
			List<NameValuePair> params = new ArrayList<NameValuePair>();
			params.add(new BasicNameValuePair("category", chosenCategory));
			params.add(new BasicNameValuePair("userID", user.getUserID()));
			
			jsonFile = Internet.Post(QUESTIONS_URL, params);

			gameSession.parseJSON(jsonFile);
			gameSession.setSessionScore(0);

			LoadQuestionsScreen.gameReady();

		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
