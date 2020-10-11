<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Insert title here</title>
<style>
    body {
        background: #000;
        display: flex;
        color: #fff;
        font-family: sans-serif;
        font-size: 2em;
        text-align: center;
    }
    .player {
        flex: 1 1 auto;
    }
    .button{
        cursor: pointer;
        background-color: #4caf50;
        margin-top: 300px;
        height: 5vh;
        width: 20vh;
    }
    canvas {
        border: solid .2em #fff;
        height: 90vh;
    }
</style>
</head>
<body>
	<h1>Game</h1>
	<div id="gameId"></div>
	<div id="gameWaitingScreen">
		<div id="consoleOne">Console one: <span></span></div>
		<div id="consoleTwo">Console two: <span></span></div>
	</div>
	<div id="gameMainScreen">
		<div class="player">
	        <div class="score"></div>
	        <canvas class="tetris" width="240" height="400"></canvas>
	    </div>
	    <button class="button" id="start_game">Start</button>
	    <div class="player">
	        <div class="score"></div>
	        <canvas class="tetris" width="240" height="400"></canvas>
	    </div>
	</div>
	<div id="gameEndScreen">
		Press restart on your console to restart game
	</div>
	
	<script src="script/utilities.js"></script>
    <script src="script/arena.js"></script>
    <script src="script/player.js"></script>
    <script src="script/tetris.js"></script>
    <script src="script/main.js"></script>
    
	<script>
		const KEY_MAPPING = [
			{ player: 1, key: 'left', keyCode: 65 }, //A
			{ player: 1, key: 'right', keyCode: 68 }, //D
			{ player: 1, key: 'rotate', keyCode: 87 }, //W
			{ player: 1, key: 'down', keyCode: 83 }, //S
			{ player: 2, key: 'left', keyCode: 37 }, //left
			{ player: 2, key: 'right', keyCode: 39 }, //right
			{ player: 2, key: 'rotate', keyCode: 38 }, //up
			{ player: 2, key: 'down', keyCode: 40 }, //down
		];
		
		let isPlaying = false;
		let isPlayerOneLost = true, isPlayerTwoLost = true;
		const id = generateId();
		let consoleIdOne = "", consoleIdTwo = "";
		document.getElementById("gameWaitingScreen").style.display = "block";
		document.getElementById("gameMainScreen").style.display = "none";
		document.getElementById("gameEndScreen").style.display = "none";
		document.getElementById('gameId').innerHTML = id;
		const socket = new WebSocket("ws://jnp-tetris.com:8080/jnp-tetris/endpoint/game/" + id);
		socket.addEventListener('open', function(event) {
			console.log(event);
		});
		socket.addEventListener('message', function(event) {
			const message = JSON.parse(event.data);
			switch(message.message) {
				case 'CONSOLE_REGISTED_TO_GAME': {
					const consoleId = message.metaData.consoleId;
					if (!consoleIdOne) {
						consoleIdOne = consoleId;
						document.querySelector("#consoleOne > span").innerHTML = consoleId;
					} else if (!!consoleIdOne && !consoleIdTwo){
						consoleIdTwo = consoleId;
						document.querySelector("#consoleTwo > span").innerHTML = consoleId;
					}
					
					if (consoleIdOne && consoleIdTwo) {
						document.getElementById("gameWaitingScreen").style.display = "none";
						document.getElementById("gameMainScreen").style.display = "flex";
						const message = {
							message: 'GAME_START',
						};
						socket.send(JSON.stringify(message));
						isPlaying = true;
						isPlayerOneLost = false;
						isPlayerTwoLost = false;
					}
					break;
				}
				case 'CONSOLE_REMOVE_FROM_GAME': {
					const consoleId = message.metaData.consoleId;
					if (consoleIdOne === consoleId) {
						consoleIdOne = "";
						document.querySelector("#consoleOne > span").innerHTML = "";
					} else if (consoleIdTwo === consoleId){
						consoleIdTwo = "";
						document.querySelector("#consoleTwo > span").innerHTML = "";
					}
					if (isPlaying) {
						alert('One player has quited');
						document.getElementById("gameWaitingScreen").style.display = "block";
						document.getElementById("gameMainScreen").style.display = "none";
						isPlaying = false;
					}
					break;
				}	
				case 'CONSOLE_PRESS_KEY': {
					console.log(message);
					const { key, consoleId } = message.metaData;
					const player = consoleId === consoleIdOne ? 1 : 2;
					const matchKey = KEY_MAPPING.filter(item => item.player === player && item.key === key);
					if (matchKey.length !== 0) {
						triggerKeyDown(matchKey[0].keyCode);
					}
					break;
				}
				case 'CONSOLE_RELEASE_KEY': {
					console.log(message);
					const { key, consoleId } = message.metaData;
					const player = consoleId === consoleIdOne ? 1 : 2;
					const matchKey = KEY_MAPPING.filter(item => item.player === player && item.key === key);
					if (matchKey.length !== 0) {
						triggerKeyUp(matchKey[0].keyCode);
					}
					
					switch (key) {
						case 'pause': {
							socket.send(JSON.stringify({
								message: 'GAME_PAUSED',
							}));
							document.getElementById("gameMainScreenMessage").innerHTML = 'Paused';
							break;
						}
						case 'resume': {
							socket.send(JSON.stringify({
								message: 'GAME_RESUMED',
							}));
							document.getElementById("gameMainScreenMessage").innerHTML = 'Playing';
							break;
						}
						case 'restart': {
							socket.send(JSON.stringify({
								message: 'GAME_RESTART',
							}));
							isPlayerOneLost = false;
							isPlayerTwoLost = false;
							document.getElementById("gameMainScreen").style.display = "flex";
							document.getElementById("gameEndScreen").style.display = "none";
							break;
						}
					}
					break;
				}
			}
			console.log(event.data);
		});
		
		function triggerKeyDown(keyCode) {
			document.dispatchEvent(new KeyboardEvent('keydown', { keyCode }));
		}
		
		function triggerKeyUp(keyCode) {
			document.dispatchEvent(new KeyboardEvent('keyup', { keyCode }));
		}
	</script>
</body>
</html>