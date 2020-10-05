package handler;

public class Room {
	private GameObject game;
	private GameObject consoleOne;
	private GameObject consoleTwo;

	public Room() {
		this.game = null;
		this.consoleOne = null;
		this.consoleTwo = null;
	}

	public Room(GameObject game) {
		this.game = game;
		this.consoleOne = null;
		this.consoleTwo = null;
	}

	public GameObject getGame() {
		return game;
	}

	public void setGame(GameObject game) {
		this.game = game;
	}

	public GameObject getConsoleOne() {
		return consoleOne;
	}

	public void setConsoleOne(GameObject consoleOne) {
		this.consoleOne = consoleOne;
	}

	public GameObject getConsoleTwo() {
		return consoleTwo;
	}

	public void setConsoleTwo(GameObject consoleTwo) {
		this.consoleTwo = consoleTwo;
	}

	public String registerConsole(GameObject console) {
		if (this.consoleOne == null) {
			this.consoleOne = console;
			return "";
		} else if (this.consoleOne != null && this.consoleTwo == null) {
			this.consoleTwo = console;
			return "";
		}
		return "full";
	}

	public void removeConsole(String consoleId) {
		if (this.consoleOne.getId().equals(consoleId)) {
			this.consoleOne = null;
		} else if (this.consoleTwo.getId().equals(consoleId)) {
			this.consoleTwo = null;
		}
	}
}
