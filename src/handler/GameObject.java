package handler;

import javax.websocket.Session;

public class GameObject {
	private String id;
	private Session session;

	public GameObject() {

	}

	public GameObject(String id, Session session) {
		this.id = id;
		this.session = session;
	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public Session getSession() {
		return session;
	}

	public void setSession(Session session) {
		this.session = session;
	}

}
