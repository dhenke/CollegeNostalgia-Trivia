package android.triviarea.data;

public class Question
{
	private String questionText;
	private String correctAnswer;
	private String[] wrongAnswer;

	public Question()
	{
		wrongAnswer = new String[3];
	}

	/**
	 * sets the wrong answers for the question
	 * @param wrongAnswer1
	 * @param wrongAnswer2
	 * @param wrongAnswer3
	 */
	public void setWrongAnswers(String wrongAnswer1, String wrongAnswer2, String wrongAnswer3)
	{
		setWrongAnswer(0, wrongAnswer1);
		setWrongAnswer(1, wrongAnswer2);
		setWrongAnswer(2, wrongAnswer3);
	}
	
	//Getters and Setters

	private void setWrongAnswer(int index, String wrongAnswer)
	{
		this.wrongAnswer[index] = wrongAnswer;
	}

	public String getQuestionText()
	{
		return questionText;
	}

	public void setQuestionText(String questionText)
	{
		this.questionText = questionText;
	}

	public String getCorrectAnswer()
	{
		return correctAnswer;
	}

	public void setCorrectAnswer(String correctAnswer)
	{
		this.correctAnswer = correctAnswer;
	}

	public String getWrongAnswer(int index)
	{
		return wrongAnswer[index];
	}
}
