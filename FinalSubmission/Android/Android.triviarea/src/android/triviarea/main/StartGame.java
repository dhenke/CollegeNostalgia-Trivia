package android.triviarea.main;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.Semaphore;

import org.apache.http.NameValuePair;
import org.apache.http.message.BasicNameValuePair;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.LightingColorFilter;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.os.Handler;
import android.triviarea.data.GameSession;
import android.triviarea.data.Question;
import android.triviarea.data.User;
import android.triviarea.utility.Internet;
import android.view.View;
import android.widget.Button;
import android.widget.SeekBar;
import android.widget.TextView;

/**
 * @author Neeraj, Sam, Chad
 * 
 */
public class StartGame extends Activity {

	// Game Data
	private GameSession gameSession;
	private Question[] questions;
	
	// UI Displays
	private Long potentialScore;	
	private SeekBar timeBar;
	private TextView questionText;
	private TextView timeText;
	private TextView questionNumberText;
	private TextView potentialScoreText;
	private TextView playerScoreText;
	private Button[] ansButtons;
	private int roundNumber;
	private boolean clickable;

	// Game Control
	private int playerSelection;
	private Long playerScore;
	private Semaphore gameLock;
	private int animationIndex;
	private int wrongIndex;
	private int gameSize;
	private static int randomInt;
	private boolean hideButtons;
	private Thread gameThread;
	private static final int MS_PER_SECOND = 1000;
	private static final int SECOND = 1000;
	private static final int FULL_BAR = 1000;
	private static final int QUESTION_TIME = 10000;
	private static final String POTENTIAL_SCORE = "1000";
	
	// Game Flow Control
	private Handler handler;
	private Timer displayAnsTimer;
	private Timer answerTimer;
	private Timer questionTimer;
	private Timer countdownTimer;
	private CountDownTimer gameTimer;
	private TimerTask displayAnswers;
	private TimerTask displaySolutionTallyPoints;
	private TimerTask startQuestion;
	private TimerTask countdown;
	private static final String COMMIT_SCORE_URL = "http://triviarea.projects.cs.illinois.edu/sendScore.php";

	// UI Attributes
	private LightingColorFilter lightBlue;
	private LightingColorFilter lightRed;
	private LightingColorFilter lightGreen;

	/** Called when the activity is restarted from the child activity */
	@Override
	public void onRestart() {
		super.onRestart();
		this.finish();
	}
	
	/** Called when the activity is destroyed/finished */
	@Override
	public void onDestroy() {
		super.onDestroy();		
		GameSession.getInstance().setSessionScore(0);
		if (gameThread != null)
			gameThread.interrupt();
	}
	
	/** Called when the activity is first created. */
	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.questionscreenclassic);
		
		/* Cancel Loading... Timer */
		LoadQuestionsScreen.loadingTimer.cancel();
		LoadQuestionsScreen.updateLoad.cancel();

		ansButtons = new Button[4];
		for (int i = 0; i < 4; i++)
			ansButtons[i] = new Button(StartGame.this);

		// Connects this UI's views based on their xml id
		setComponentsById();

		gameSession = GameSession.getInstance();
		questions = gameSession.getQuestion();

		wrongIndex = 0;
		gameSize = gameSession.getNumOfRounds();

		// On click listeners for Answer buttons
		createButtonActionListeners();

		lightBlue = new LightingColorFilter(0xFFFFFFFF, 0xFF1100AA);
		lightRed = new LightingColorFilter(0xFFFFFFFF, 0xFFFF00FF);
		lightGreen = new LightingColorFilter(0xFFFFFFFF, 0xFF00FF00);

		handler = new Handler();
		displayAnsTimer = new Timer();
		answerTimer = new Timer();
		questionTimer = new Timer();
		countdownTimer = new Timer();
		hideButtons = true;

		gameThread = new Thread() {
			public void run() {
				try {
					
					// Controls the game flow for each question.
					gameLock = new Semaphore(0);
					
					Random randomGenerator = new Random();

					for (roundNumber = 0; roundNumber < gameSize; roundNumber++) {

						playerSelection = -1;

						randomInt = randomGenerator.nextInt(4);

						setUpGameTimerTasks();

						questionTimer.schedule(startQuestion, 100); // FREE

						gameLock.acquire(); // LOCK

						displayAnsTimer.schedule(displayAnswers, 1500); // FREE

						gameLock.acquire(); // LOCK
						
						//if(countdownTimer == null)
						countdownTimer = new Timer();
						countdownTimer.schedule(countdown, 10); // FREE

						gameLock.acquire(); // LOCK

						answerTimer.schedule(displaySolutionTallyPoints, 3000); // FREE

						gameLock.acquire(); // LOCK
					}

					commitScore();
					
					// Game Finished - Proceed to EndGame
					timerDestroy();
					Intent i = new Intent("android.triviarea.main.EndGame");
					startActivity(i);
					
				} catch (InterruptedException e) {
					//e.printStackTrace();
				}
			}
		};
		gameThread.start();
	}

	/**
	 * Initializes UI components by matching their layout id's to the objects.
	 */
	private void setComponentsById() {
		ansButtons[0] = (Button) findViewById(R.id.ans1);
		ansButtons[1] = (Button) findViewById(R.id.ans2);
		ansButtons[3] = (Button) findViewById(R.id.ans3);
		ansButtons[2] = (Button) findViewById(R.id.ans4);
		timeBar = (SeekBar) findViewById(R.id.seekBar1);
		questionText = (TextView) findViewById(R.id.question);
		questionNumberText = (TextView) findViewById(R.id.questionNumber);
		playerScoreText = (TextView) findViewById(R.id.playerScore);
		potentialScoreText = (TextView) findViewById(R.id.potentialScore);
		timeText = (TextView) findViewById(R.id.secondsRemaining);
	}
	
	/**
	 * Sends the score to the server for the 
	 * current user at the end of a game. 
	 * @param score
	 */
	private void commitScore(){
		String score = gameSession.getSessionScore().toString();

		try {
			GameSession gameSession = GameSession.getInstance();
			User user = User.getInstance();
			String chosenCategory = gameSession.getPlayCategory();
			
			List<NameValuePair> params = new ArrayList<NameValuePair>();
			params.add(new BasicNameValuePair("category", chosenCategory));
			params.add(new BasicNameValuePair("userID", user.getUserID()));
			params.add(new BasicNameValuePair("score", score));
			
			Internet.Post(COMMIT_SCORE_URL, params);

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * The game's flow is controlled by a relay of timertasks which hand off a
	 * semaphore in order to protect the flow and keep it consistent.
	 * 
	 * These timer tasks perform the necessary functions when they are called.
	 * 
	 */
	private void setUpGameTimerTasks() {
		/*
		 * This randomizes the order of the possible questions and assigns them.
		 * The question is also displayed.
		 */
		startQuestion = new TimerTask() {
			public void run() {
				handler.post(new Runnable() {
					public void run() {

						clickable = true;

						// Set random questions
						for (int i = 0; i < 4; i++) {

							ansButtons[i].setEnabled(false);

							if (randomInt == i)
								ansButtons[i].setText(questions[roundNumber]
										.getCorrectAnswer());
							else

								ansButtons[i].setText(questions[roundNumber]
										.getWrongAnswer(wrongIndex++));

						}
						// Display initial information
						questionText.setText(questions[roundNumber]
								.getQuestionText());
						playerScoreText.setText("0000");
						potentialScoreText.setText(POTENTIAL_SCORE);
						questionNumberText.setText("Question "
								+ (roundNumber + 1) + "/" + gameSize);
						playerScoreText.setTextColor(Color.LTGRAY);
						wrongIndex = 0;

						gameLock.release();
					
					}
					
				});
			}
		};

		/*
		 * Displays the answers in a delayed loop so that they appear to
		 * 'fan-out' on the screen.
		 */
		displayAnswers = new TimerTask() {
			public void run() {
				handler.post(new Runnable() {
					public void run() {

						animationIndex = 0;

						new CountDownTimer(800, 150) {

							@Override
							public void onFinish() {
								hideButtons = false;
								for (int i = 0; i < 4; i++) {
									ansButtons[i].setVisibility(View.VISIBLE);
									ansButtons[i].setEnabled(true);
								}
								gameLock.release();

							}

							@Override
							public void onTick(long msLeft) {
								if (hideButtons && animationIndex < 4) {
									ansButtons[animationIndex]
											.setVisibility(View.VISIBLE);
									animationIndex++;
								}

							}
						}.start();

					}

				});
			}
		};

		/*
		 * Used to update the timeBar, potential points, and time. When it
		 * finishes it displays the correct/incorrect solutions and resets the
		 * values.
		 */
		countdown = new TimerTask() {
			public void run() {
				handler.post(new Runnable() {
					public void run() {

						timeBar.setProgress(FULL_BAR);

						gameTimer = new CountDownTimer(QUESTION_TIME, 10) {

							@Override
							public void onFinish() {
								// Display correct/wrong answer
								answerCheck();
								
							}

							@Override
							public void onTick(long msLeft) {
								// // Updating the seconds remaining
								String time = Long
										.toString((msLeft + SECOND) / MS_PER_SECOND);
								timeText.setText(time);
								timeBar.setProgress((int) (msLeft / 10));

								// // Updating the score
								potentialScore = msLeft/10;
								String score = Long.toString(potentialScore);
								potentialScoreText.setText(score);
							}
						}.start();

					}

				});
			}
		};

		/*
		 * This resets the buttons and rehides everything before the start of
		 * the next round.
		 */
		displaySolutionTallyPoints = new TimerTask() {
			public void run() {
				handler.post(new Runnable() {
					public void run() {

						animationIndex = 0;

						new CountDownTimer(800, 150) {

							@Override
							public void onFinish() {
								hideButtons = true;
								animationIndex = 0;
								for (int i = 0; i < 4; i++) {
									ansButtons[i].setVisibility(View.INVISIBLE);
								}
								resetButtons(-1);
								gameLock.release();
							}

							@Override
							public void onTick(long msLeft) {
								if (!hideButtons && animationIndex < 4) {
									ansButtons[animationIndex]
											.setVisibility(View.INVISIBLE);
									animationIndex++;
								}

							}
						}.start();
					}

				});
			}
		};
	}

	/**
	 * answerCheck takes the player's answers at the end of the round and awards
	 * points if necessary. It also displays the correct answer and highlights
	 * incorrect selections.
	 * 
	 */
	private void answerCheck() {
		resetButtons(-1);
		clickable = false;

		// If the player is incorrect, then we set their choice to red.
		// Score text is also turned red.
		if (randomInt != playerSelection && playerSelection > -1) {
			ansButtons[playerSelection].getBackground()
					.setColorFilter(lightRed);
			playerScoreText.setTextColor(Color.RED);
		}

		// Retrieves session score and adds this current round to it if the
		// player is correct. Green score text color.
		if (randomInt == playerSelection && playerSelection > -1) {
			gameSession.setSessionScore((Long) playerScore
					+ gameSession.getSessionScore());
			playerScoreText.setTextColor(Color.GREEN);
		}

		// The correct answer is shown.
		ansButtons[randomInt].getBackground().setColorFilter(lightGreen);

		redrawButtons();
		
		// Reset displays for next question
		timeText.setText("11");
		timeBar.setProgress(FULL_BAR);
		potentialScoreText.setText("0");
		
		gameLock.release();
		
	}

	private void redrawButtons() {
		for (int i = 0; i < 4; i++)
			ansButtons[i].invalidate();
	}

	/**
	 * Creates the 4 button listeners for each possible answer.
	 */
	private void createButtonActionListeners() {

		// Click Listeners
		ansButtons[0].setOnClickListener(new View.OnClickListener() {
			public void onClick(View view) {
				answerSelect(0);
			}
		});
		ansButtons[1].setOnClickListener(new View.OnClickListener() {
			public void onClick(View view) {
				answerSelect(1);
			}
		});
		ansButtons[2].setOnClickListener(new View.OnClickListener() {
			public void onClick(View view) {
				answerSelect(2);
			}
		});
		ansButtons[3].setOnClickListener(new View.OnClickListener() {
			public void onClick(View view) {
				answerSelect(3);
			}
		});
		//*
		//Long Click Listeners
		ansButtons[0].setOnLongClickListener(new View.OnLongClickListener() {
			public boolean onLongClick(View view) {
				answerSelect(0);				
				answerCheck();
				
				gameTimer.cancel();
				countdownTimer.cancel();
				
				return true;
			}
		});
		ansButtons[1].setOnLongClickListener(new View.OnLongClickListener() {
			public boolean onLongClick(View view) {
				answerSelect(1);
				answerCheck();
				
				gameTimer.cancel();
				countdownTimer.cancel();
				
				return true;
			}
		});
		ansButtons[2].setOnLongClickListener(new View.OnLongClickListener() {
			public boolean onLongClick(View view) {
				answerSelect(2);
				answerCheck();
				
				gameTimer.cancel();
				countdownTimer.cancel();
				
				return true;
			}
		});
		ansButtons[3].setOnLongClickListener(new View.OnLongClickListener() {
			public boolean onLongClick(View view) {
				answerSelect(3);
				answerCheck();
				
				gameTimer.cancel();
				countdownTimer.cancel();
				
				return true;
			}
		});
		//*/
	}
	
	/**
	 * answerSelect is used by the button listeners for setting text view, score values, and drawable colors.
	 */
	private void answerSelect(int selection) {
		if (!clickable)
			return;
		
		if (playerSelection != selection) {
			playerScoreText.setText(potentialScoreText.getText());
			playerScore = potentialScore;
			playerSelection = selection;
			resetButtons(selection);
			ansButtons[selection].getBackground().setColorFilter(lightBlue);
		}
	}

	/**
	 * resetButtons is called whenever the buttons need to be set to their
	 * original colors.
	 * 
	 * @param avoid
	 *            the index of the button to avoid. (0-3) Preferably -1 if o/w.
	 */
	private void resetButtons(final int avoid) {
		for (int i = 0; i < 4; i++) {
			if (i != avoid)
				ansButtons[i].getBackground().setColorFilter(null);
			ansButtons[i].invalidate();
		}
	}
	
	/**
	 * timerDestroy ensure that all timers belonging to the game are destroyed.
	 */
	private void timerDestroy(){
		displayAnsTimer.cancel();
		answerTimer.cancel();
		questionTimer.cancel();
		countdownTimer.cancel();
		displayAnswers.cancel();
		displaySolutionTallyPoints.cancel();
		startQuestion.cancel();
		countdown.cancel();
	}
}
