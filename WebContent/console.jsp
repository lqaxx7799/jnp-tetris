<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Insert title here</title>
</head>
<body>
	<h1>Console</h1>
	<div id="consoleId"></div>
	<div id="homeScreen">
		<input type="text" id="txtRoomId" />
		<button id="btnJoin">Join</button>
	</div>
	<div id="waitingScreen">
		<div>Waiting other player to join</div>
		<button id="btnQuit">Quit</button>
	</div>
	<div id="consoleScreen">
		<button class="btnSend" data-key="left">Left</button>
		<button class="btnSend" data-key="right">Right</button>
		<button class="btnSend" data-key="down">Down</button>
		<button class="btnSend" data-key="rotate">Rotate</button>
		<button class="btnSend" data-key="pause">Pause</button>
		<button class="btnSend" data-key="quit">Quit</button>
	</div>
	<script src="script/utilities.js"></script>
	<script>
		//init
		document.getElementById("homeScreen").style.display = "block";
		document.getElementById("waitingScreen").style.display = "none";
		document.getElementById("consoleScreen").style.display = "none";
		const id = generateId();
		document.getElementById("consoleId").innerHTML = id;
		let socket;
		
		document.getElementById('btnJoin').addEventListener('click', function() {
			const roomId = document.getElementById('txtRoomId').value;
			socket = new WebSocket('ws://127.0.0.1:8080/jnp-tetris/endpoint/console/' + id + '?roomId=' + roomId);
			document.getElementById("homeScreen").style.display = "none";
			document.getElementById("waitingScreen").style.display = "block";
			socket.addEventListener('open', function(event) {
				console.log(event);
			});
			socket.addEventListener('message', function(event) {
				console.log(event.data);
				const message = JSON.parse(event.data);
				switch(message.message) {
					case 'GAME_START': {
						document.getElementById("waitingScreen").style.display = "none";
						document.getElementById("consoleScreen").style.display = "block";
					}
				}
			});
		});
		
		document.getElementById('btnQuit').addEventListener('click', function() {
			socket.close();
			document.getElementById("homeScreen").style.display = "block";
			document.getElementById("waitingScreen").style.display = "none";
		});

		document.querySelectorAll('.btnSend').forEach(element => {
			const key = element.dataset.key;
			element.addEventListener('click', () => {
				const message = {
					message: 'CONSOLE_PRESS_KEY',
					metaData: {
						key,
						consoleId: id,
					},
				};
				socket.send(JSON.stringify(message));
			});
		});
	</script>
</body>
</html>