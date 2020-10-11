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
		<button id="btnQuitWaiting">Quit</button>
	</div>
	<div id="consoleScreen">
		<button id="btnLeft">Left</button>
		<button id="btnRight">Right</button>
		<button id="btnDown">Down</button>
		<button id="btnRotate">Rotate</button>
		<button id="btnPause">Pause</button>
		<button id="btnResume" style="display: none">Resume</button>
		<button id="btnQuit">Quit</button>
	</div>
	<div id="endScreen">
		You lost. Your score is <span id="scoreText"></span>
		<div id="endMessageWaiting">Waiting for the other player to lose</div>
		<div id="endMessageFinishing" style="display: none">
			<button id="btnRestart">Restart</button>
			<button id="btnQuitEnding">Quit</button>
		</div>
	</div>

	<script src="script/utilities.js"></script>
	<script>
		const KEY_MAPPING = [
			{ key: 'left', keyCode: 37 }, //left
			{ key: 'right', keyCode: 39 }, //right
			{ key: 'rotate', keyCode: 38 }, //up
			{ key: 'down', keyCode: 40 }, //down
		];
		//init
		let isPlaying = false;
		document.getElementById("homeScreen").style.display = "block";
		document.getElementById("waitingScreen").style.display = "none";
		document.getElementById("consoleScreen").style.display = "none";
		document.getElementById("endScreen").style.display = "none";
		const id = generateId();
		document.getElementById("consoleId").innerHTML = id;
		let socket;
		
		document.getElementById('btnJoin').addEventListener('click', function() {
			const roomId = document.getElementById('txtRoomId').value;
			socket = new WebSocket('ws://jnp-tetris.com:8080/jnp-tetris/endpoint/console/' + id + '?roomId=' + roomId);
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
						isPlaying = true;
						break;
					}
					case 'GAME_REMOVE': {
						alert('Game is removed');
						document.getElementById("homeScreen").style.display = "block";
						document.getElementById("waitingScreen").style.display = "none";
						document.getElementById("consoleScreen").style.display = "none";
						document.getElementById("endScreen").style.display = "none";
						socket.close();
						isPlaying = false;
						break;
					}
					case 'GAME_RESTART': {
						document.getElementById("consoleScreen").style.display = "block";
						document.getElementById("endScreen").style.display = "none";
						break;
					}
					case 'GAME_CONSOLE_LOST': {
						if (message.metaData.consoleId === id) {
							document.getElementById("consoleScreen").style.display = "none";
							document.getElementById("endScreen").style.display = "block";
							document.getElementById("scoreText").innerHTML = message.metaData.score;
						}
						break;
					}
					case 'GAME_OVER': {
						document.getElementById("endMessageWaiting").style.display = "none";
						document.getElementById("endMessageFinishing").style.display = "block";
						break;
					}
					case 'CONSOLE_REGISTED_TO_GAME_FAILED': {
						const { error } = message.metaData;
						if (error === 'ROOM_NOT_EXIST') {
							alert('This room does not exist!');
						} else if (error === 'ROOM_FULL') {
							alert('This room is full!');
						}	
						closeSocket();
						break;
					}
					case 'CONSOLE_REMOVE_FROM_GAME': {
						if (isPlaying) {
							alert('One player has quited');
							document.getElementById("homeScreen").style.display = "none";
							document.getElementById("waitingScreen").style.display = "block";
							document.getElementById("consoleScreen").style.display = "none";
							isPlaying = false;
						}
						break;
					}	
					case 'CONSOLE_RELEASE_KEY': {
						const { key } = message.metaData;
						if (key === 'pause') {
							document.getElementById('btnPause').style.display = 'none';
							document.getElementById('btnResume').style.display = 'inline-block';
						} else if (key === 'resume') {
							document.getElementById('btnResume').style.display = 'none';
							document.getElementById('btnPause').style.display = 'inline-block';
						}
						break;
					}	
				}
			});
		});
		
		document.getElementById('btnQuitWaiting').addEventListener('click', closeSocket);
		
		document.getElementById('btnLeft').addEventListener('click', () => {
			sendConsolePressKeyMessage('left');
			sendConsoleReleaseKeyMessage('left');
		});
		
		document.getElementById('btnRight').addEventListener('click', () => {
			sendConsolePressKeyMessage('right');
			sendConsoleReleaseKeyMessage('right');
		});
				
		document.getElementById('btnDown').addEventListener('click', () => {
			sendConsolePressKeyMessage('down');
			sendConsoleReleaseKeyMessage('down');
		});
		
		document.getElementById('btnRotate').addEventListener('click', () => {
			sendConsolePressKeyMessage('rotate');
			sendConsoleReleaseKeyMessage('rotate');
		});
		
		document.getElementById('btnPause').addEventListener('click', () => {
			sendConsolePressKeyMessage('pause');
			sendConsoleReleaseKeyMessage('pause');
			document.getElementById('btnPause').style.display = 'none';
			document.getElementById('btnResume').style.display = 'inline-block';
		});
		
		document.getElementById('btnResume').addEventListener('click', () => {
			sendConsolePressKeyMessage('resume');
			sendConsoleReleaseKeyMessage('resume');
			document.getElementById('btnResume').style.display = 'none';
			document.getElementById('btnPause').style.display = 'inline-block';
		});
		
		document.getElementById('btnQuit').addEventListener('click', closeSocket);

		document.getElementById('btnQuitEnding').addEventListener('click', closeSocket);
		
		document.getElementById('btnRestart').addEventListener('click', () => {
			sendConsolePressKeyMessage('restart');
			sendConsoleReleaseKeyMessage('restart');
		});
		
		document.addEventListener('keydown', (e) => {
			const matchKey = KEY_MAPPING.filter(item => item.keyCode === e.keyCode);
			if (matchKey.length !== 0) {
				sendConsolePressKeyMessage(matchKey[0].key);
			}
		});
		
		document.addEventListener('keyup', (e) => {
			const matchKey = KEY_MAPPING.filter(item => item.keyCode === e.keyCode);
			if (matchKey.length !== 0) {
				sendConsoleReleaseKeyMessage(matchKey[0].key);
			}
		});
		
		function sendConsolePressKeyMessage(key) {
			if (socket) {
				const message = {
					message: 'CONSOLE_PRESS_KEY',
					metaData: {
						key,
						consoleId: id,
					},
				};
				socket.send(JSON.stringify(message));
			}	
		}
		
		function sendConsoleReleaseKeyMessage(key) {
			if (socket) {
				const message = {
					message: 'CONSOLE_RELEASE_KEY',
					metaData: {
						key,
						consoleId: id,
					},
				};
				socket.send(JSON.stringify(message));
			}	
		}
		
		function closeSocket() {
			if (socket) {
				socket.close();
				document.getElementById("homeScreen").style.display = "block";
				document.getElementById("waitingScreen").style.display = "none";
				document.getElementById("consoleScreen").style.display = "none";
			}
		}
	</script>
</body>
</html>