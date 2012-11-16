package android.triviarea.threads;


import java.util.ArrayList;
import java.util.List;
import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;
import android.triviarea.data.GameSession;
import android.triviarea.utility.Internet;
import android.util.Log;


/**
 *
 * This thread serves as a background service that retrieves the leaderboard from the server
 * 
 */
public class LeaderboardThread extends Thread {

	private static final String LDBD_URL = "http://triviarea.projects.cs.illinois.edu/retrieveLeaderboard.php";

	public LeaderboardThread() {
		super();
	}

	@Override
	public void run() {

		try {
			Log.e("LDBD", "Why Hello there, leaderboard");
			GameSession gameSession = GameSession.getInstance();

			String chosenCategory = gameSession.getLeaderboardCategory();
			String jsonFile = null;
			Log.e("LDBD",chosenCategory);
			
			List<NameValuePair> params = new ArrayList<NameValuePair>();
			params.add(new BasicNameValuePair("category", chosenCategory));
			
			jsonFile = Internet.Post(LDBD_URL, params);
			Log.e("LDBD", jsonFile);

		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
