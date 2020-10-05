package socket;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URI;
import java.net.URLDecoder;
import java.util.LinkedHashMap;
import java.util.Map;

import javax.websocket.OnClose;
import javax.websocket.OnError;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.PathParam;
import javax.websocket.server.ServerEndpoint;

import handler.GameHandler;

@ServerEndpoint(value = "/endpoint/{type}/{id}")
public class GameSocket {
	@OnOpen
	public void onOpen(Session session, @PathParam("type") String type, @PathParam("id") String id) throws IOException {
		System.out.println("onOpen::" + id + " " + type);
		GameHandler.initialize();
		if (type.equals("game")) {
			GameHandler.addRoom(id, session);
		} else if (type.equals("console")) {
			URI uri = session.getRequestURI();
			Map<String, String> query = splitQuery(uri);
			String roomId = query.get("roomId");
			GameHandler.addConsoleToRoom(roomId, id, session);
		}
	}

	@OnClose
	public void onClose(Session session, @PathParam("type") String type, @PathParam("id") String id)
			throws IOException {
		System.out.println("onClose::" + id + " " + type);
		if (type.equals("game")) {
			GameHandler.removeRoom(id);
		} else if (type.equals("console")) {
			URI uri = session.getRequestURI();
			Map<String, String> query = splitQuery(uri);
			String roomId = query.get("roomId");
			GameHandler.removeConsoleFromRoom(roomId, id);
		}
	}

	@OnMessage
	public void onMessage(String message, Session session, @PathParam("type") String type, @PathParam("id") String id) {
		System.out.println("onMessage::From=" + id + " " + type + " Message=" + message);
		if (type.equals("game")) {
			GameHandler.sendMessageByGame(message, id);
		} else if (type.equals("console")) {
			GameHandler.sendMessageByConsole(message, id);
		}
	}

	@OnError
	public void onError(Throwable t) {
		System.out.println("onError::" + t.getMessage());
	}

	public static Map<String, String> splitQuery(URI uri) throws UnsupportedEncodingException {
		Map<String, String> query_pairs = new LinkedHashMap<String, String>();
		String query = uri.getQuery();
		String[] pairs = query.split("&");
		for (String pair : pairs) {
			int idx = pair.indexOf("=");
			query_pairs.put(URLDecoder.decode(pair.substring(0, idx), "UTF-8"),
					URLDecoder.decode(pair.substring(idx + 1), "UTF-8"));
		}
		return query_pairs;
	}
}