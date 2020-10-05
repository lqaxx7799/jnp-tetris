<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Insert title here</title>
</head>
<body>
	<h1>Game</h1>
	<div id="gameId"></div>
	<div id="gameWaitingScreen">
		<div id="consoleOne">Console one: <span></span></div>
		<div id="consoleTwo">Console two: <span></span></div>
	</div>
	<div id="gameMainScreen">
		Playing...
	</div>
	<script src="script/utilities.js"></script>
	<script>
		const id = generateId();
		let consoleIdOne = "", consoleIdTwo = "";
		document.getElementById("gameWaitingScreen").style.display = "block";
		document.getElementById("gameMainScreen").style.display = "none";
		document.getElementById('gameId').innerHTML = id;
		const socket = new WebSocket("ws://127.0.0.1:8080/jnp-tetris/endpoint/game/" + id);
		socket.addEventListener('open', function(event) {
			console.log(event);
		});
		socket.addEventListener('message', function(event) {
			const message = JSON.parse(event.data);
			switch(message.message) {
				case 'CONSOLE_REGISTED_TO_GAME': {
					const consoleId = message.metaData.consoleId;
					if(!consoleIdOne) {
						consoleIdOne = consoleId;
						document.querySelector("#consoleOne > span").innerHTML = consoleId;
					} else if (!!consoleIdOne && !consoleIdTwo){
						consoleIdTwo = consoleId;
						document.querySelector("#consoleTwo > span").innerHTML = consoleId;
					}
					
					if(consoleIdOne && consoleIdTwo) {
						document.getElementById("gameWaitingScreen").style.display = "none";
						document.getElementById("gameMainScreen").style.display = "block";
						const message = {
							message: 'GAME_START',
						};
						socket.send(JSON.stringify(message));
					}
					break;
				}
				case 'CONSOLE_REMOVE_FROM_GAME': {
					const consoleId = message.metaData.consoleId;
					if(consoleIdOne === consoleId) {
						consoleIdOne = "";
						document.querySelector("#consoleOne > span").innerHTML = "";
					} else if (consoleIdTwo === consoleId){
						consoleIdTwo = "";
						document.querySelector("#consoleTwo > span").innerHTML = "";
					}
					break;
				}	
				case 'CONSOLE_PRESS_KEY': {
					console.log(message);
					break;
				}
			}
			console.log(event.data);
		});
	</script>
</body>
</html>