package android.triviarea.main;

import java.util.Calendar;
import android.app.Activity;
import android.os.Bundle;
import android.triviarea.data.GameSession;
import android.widget.TextView;

public class LeaderboardScreen extends Activity {
	
	private GameSession gameSession;

	/** Called when the activity is first created. */
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.leaderboardscreen);

		gameSession = GameSession.getInstance();		
		setCategory();
		setDate();
	
		TextView leaderboardUserString = (TextView) findViewById(R.id.leaderboarduserstring);
		TextView leaderboardScoreString = (TextView) findViewById(R.id.leaderboardscorestring);
		
		leaderboardUserString.setText(gameSession.getLeaderboardUserString());
		leaderboardScoreString.setText(gameSession.getLeaderboardScoreString());
	}
	
	/**
	 * setCategory retrieves the chosen leaderboard category and displays it on screen.
	 */
	public void setCategory() {
		TextView category = (TextView) findViewById(R.id.leaderboardcategory);		
		category.setText(gameSession.getLeaderboardCategory());
	}
	
	/**
	 * setDate retrieves the current day, month, and year and displays them on screen.
	 */
	public void setDate() {
		
		String[] monthName = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November",	"December"};

		Calendar c = Calendar.getInstance();
		
		String month = monthName[c.get(Calendar.MONTH)];
		String date = new Integer(c.get(Calendar.DATE)).toString();
		String year = new Integer(c.get(Calendar.YEAR)).toString();
		
		String wholeDate = date + " " + month + " " + year;
		
		TextView theDate = (TextView) findViewById(R.id.todayDate);
		
		theDate.setText(wholeDate);
	}
	
}
