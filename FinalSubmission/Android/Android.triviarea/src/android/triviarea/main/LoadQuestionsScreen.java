package android.triviarea.main;

import java.util.Timer;
import java.util.TimerTask;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.triviarea.data.GameSession;
import android.widget.TextView;

public class LoadQuestionsScreen extends Activity {
	
	private GameSession gameSession;
	public static TimerTask updateLoad;
	public static Timer loadingTimer;
	private Handler handler;
	private int dots = 0;
	private int sum = 0;
	private static boolean gameReady = false;

	/** Called when the activity is first created. */
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.loadingscreen);
		gameSession = GameSession.getInstance();
		setUpRunnables();
		loadingTimer.schedule(updateLoad, 333, 333);
	}

	/** Called when the activity is restarted. */
	@Override
	public void onRestart() {
		super.onRestart();
		this.finish();
	}

	/**
	 * This is the code that runs in the threads
	 */
	private void setUpRunnables() {

		handler = new Handler();
		loadingTimer = new Timer();

		updateLoad = new TimerTask() {
			public void run() {
				handler.post(new Runnable() {
					public void run() {

						if (gameReady) {
							Intent i = new Intent(
									"android.triviarea.main.StartGame");
							startActivity(i);
						}

						TextView loadingText = (TextView) findViewById(R.id.loading);
					
						dots = sum % 4;
						switch (dots) {
						case 4:
							dots = 0;
						case 0:
							loadingText.setText("Loading");
							break;
						case 1:
							loadingText.setText("Loading.");
							break;
						case 2:
							loadingText.setText("Loading..");
							break;
						case 3:
							loadingText.setText("Loading...");
							break;
						}
						sum++;
					}

				});
			}
		};
	}

	public static void gameReady() {
		gameReady = true;
	}
}
