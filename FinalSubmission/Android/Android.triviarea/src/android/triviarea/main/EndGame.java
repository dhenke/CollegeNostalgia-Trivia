package android.triviarea.main;

import java.util.Timer;
import java.util.TimerTask;

import android.app.Activity;
import android.os.Bundle;
import android.os.Handler;
import android.triviarea.data.GameSession;
import android.widget.TextView;

public class EndGame extends Activity {

	private TimerTask mainMenuRewind;
	private Handler handler;
	private Timer endScreenTimer;
	private GameSession gameSession;
	private TextView playerScore;

	/** Called when the activity is first created. */
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.endgame);
		gameSession = GameSession.getInstance();

		playerScore = (TextView) findViewById(R.id.endGameScore);
		String score = gameSession.getSessionScore().toString();
		playerScore.setText("Score: " + score);
		
		setupTimerTasks();
		endScreenTimer.schedule(mainMenuRewind, 4000);
	}

	private void setupTimerTasks() {

		handler = new Handler();
		endScreenTimer = new Timer();

		mainMenuRewind = new TimerTask() {
			public void run() {
				handler.post(new Runnable() {
					public void run() {
						EndGame.this.finish();
					}
				});
			}
		};
	}

}
