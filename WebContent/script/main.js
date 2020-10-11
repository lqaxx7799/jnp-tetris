function createPiece(type) {
    if (type === 'T') {
        return [
            [0, 0, 0],
            [1, 1, 1],
            [0, 1, 0],
        ];
    } else if (type === 'O') {
        return [
            [2, 2],
            [2, 2],
        ];
    } else if (type === 'L') {
        return [
            [0, 3, 0],
            [0, 3, 0],
            [0, 3, 3],
        ];
    } else if (type === 'J') {
        return [
            [0, 4, 0],
            [0, 4, 0],
            [4, 4, 0],
        ];
    } else if (type === 'I') {
        return [
            [0, 5, 0, 0],
            [0, 5, 0, 0],
            [0, 5, 0, 0],
            [0, 5, 0, 0],
        ];
    } else if (type === 'S') {
        return [
            [0, 6, 6],
            [6, 6, 0],
            [0, 0, 0],
        ];
    } else if (type === 'Z') {
        return [
            [7, 7, 0],
            [0, 7, 7],
            [0, 0, 0],
        ];
    }
}
function getRandomString(length) {
        var randomChars = 'TOLJISZ';
        var result = '';
        for ( var i = 0; i < length; i++ ) {
         result += randomChars.charAt(Math.floor(Math.random() * randomChars.length));
        }
     return result;
    }

const pieces = getRandomString(1000);

const tetri = [];

const playerElements = document.querySelectorAll('.player');
[...playerElements].forEach(element => {
    const tetris = new Tetris(element);
    tetri.push(tetris);
});

const button = document.getElementById('start_game');
button.disabled = true;

button.addEventListener('click', function(){
    if(tetri[0].player.over && tetri[1].player.over){
        location.reload();
        return false;
    }
    else
        button.disabled = true;    

});

const keyListener = (event) => {
    [
        [65, 68, 87, 83],
        [37, 39, 38, 40],
    ].forEach((key, index) => {
        const player = tetri[index].player;
        if (event.type === 'keydown') {
            if (event.keyCode === key[0]) {
                player.move(-1);
            } else if (event.keyCode === key[1]) {
                player.move(1);
            } else if (event.keyCode === key[2]) {
                player.rotate(1);
            }
        }

        if (event.keyCode === key[3]) {
            if (event.type === 'keydown') {
                if (player.dropInterval !== player.DROP_FAST) {
                    player.drop();
                    player.dropInterval = player.DROP_FAST;
                }
            } else {
                player.dropInterval = player.DROP_SLOW;
            }
        }
    });
};


document.addEventListener('keydown', keyListener);
document.addEventListener('keyup', keyListener);

document.addEventListener('keydown', function(e) {
    var key = e.keyCode;
    if(key === 80){
        tetri[0].player.pause();
        tetri[1].player.pause();
    }
});


