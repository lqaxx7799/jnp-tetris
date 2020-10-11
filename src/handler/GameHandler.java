package handler;

import java.io.IOException;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

import javax.websocket.Session;

import com.google.gson.Gson;

public class GameHandler {
	private static GameHandler instance;
	private static Map<String, Room> rooms = new HashMap<>();

	private GameHandler() {
	}

	public static void initialize() {
		if (instance == null) {
			instance = new GameHandler();
		}
	}

	public static void addRoom(String id, Session gameSession) {
		rooms.put(id, new Room(new GameObject(id, gameSession)));
	}

	public static void removeRoom(String id) throws IOException {
		Room room = rooms.get(id);
		GameMessage gameMessage = new GameMessage(GameMessageConstants.GAME_REMOVE, null);
		String message = new Gson().toJson(gameMessage);
		if (room.getConsoleOne() != null) {
			room.getConsoleOne().getSession().getBasicRemote().sendText(message);
		}
		if (room.getConsoleTwo() != null) {
			room.getConsoleTwo().getSession().getBasicRemote().sendText(message);
		}
		rooms.remove(id);
	}

	public static void addConsoleToRoom(String roomId, String consoleId, Session consoleSession) throws IOException {
		Room room = rooms.get(roomId);
		if (room == null) {
			Map<String, String> metaData = new LinkedHashMap<>();
			metaData.put("error", "ROOM_NOT_EXIST");
			GameMessage gameMessage = new GameMessage(GameMessageConstants.CONSOLE_REGISTED_TO_GAME_FAILED, metaData);
			String message = new Gson().toJson(gameMessage);
			consoleSession.getBasicRemote().sendText(message);
			return;
		}
		String registerMessage = room.registerConsole(new GameObject(consoleId, consoleSession));
		if (!registerMessage.equals("")) {
			Map<String, String> metaData = new LinkedHashMap<>();
			metaData.put("error", registerMessage);
			GameMessage gameMessage = new GameMessage(GameMessageConstants.CONSOLE_REGISTED_TO_GAME_FAILED, metaData);
			String message = new Gson().toJson(gameMessage);
			consoleSession.getBasicRemote().sendText(message);
			return;
		}
		rooms.replace(roomId, room);
		Map<String, String> metaData = new LinkedHashMap<>();
		metaData.put("consoleId", consoleId);
		GameMessage gameMessage = new GameMessage(GameMessageConstants.CONSOLE_REGISTED_TO_GAME, metaData);
		String message = new Gson().toJson(gameMessage);
		room.getGame().getSession().getBasicRemote().sendText(message);
	}

	public static void removeConsoleFromRoom(String roomId, String consoleId) throws IOException {
		Room room = rooms.get(roomId);
		if (room == null) {
			return;
		}
		room.removeConsole(consoleId);
		rooms.replace(roomId, room);
		Map<String, String> metaData = new LinkedHashMap<>();
		metaData.put("consoleId", consoleId);
		GameMessage gameMessage = new GameMessage(GameMessageConstants.CONSOLE_REMOVE_FROM_GAME, metaData);
		String message = new Gson().toJson(gameMessage);
		room.getGame().getSession().getBasicRemote().sendText(message);
		if (room.getConsoleOne() != null) {
			room.getConsoleOne().getSession().getBasicRemote().sendText(message);
		}
		if (room.getConsoleTwo() != null) {
			room.getConsoleTwo().getSession().getBasicRemote().sendText(message);
		}
	}

	public static void sendMessageByGame(String message, String gameId) {
//		GameMessage gameMessage = new Gson().fromJson(message, GameMessage.class);
		try {
			for (String key : rooms.keySet()) {
				Room room = rooms.get(key);
				if (room.getGame().getId().equals(gameId)) {
					System.out.println("Game: " + message);
					room.getConsoleOne().getSession().getBasicRemote().sendText(message);
					room.getConsoleTwo().getSession().getBasicRemote().sendText(message);
				}
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	public static void sendMessageByConsole(String message, String consoleId) {
		try {
			for (String key : rooms.keySet()) {
				Room room = rooms.get(key);
				if (room.getConsoleOne().getId().equals(consoleId)) {
					System.out.println("Player 1: " + message);
					room.getGame().getSession().getBasicRemote().sendText(message);
					room.getConsoleTwo().getSession().getBasicRemote().sendText(message);
				} else if (room.getConsoleTwo().getId().equals(consoleId)) {
					System.out.println("Player 2: " + message);
					room.getGame().getSession().getBasicRemote().sendText(message);
					room.getConsoleOne().getSession().getBasicRemote().sendText(message);
				}
			}
		} catch (IOException ex) {
			ex.printStackTrace();
		}

	}
}
