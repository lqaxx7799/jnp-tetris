class Player
{
    constructor(tetris)
    {
        this.DROP_SLOW = 850;
        this.DROP_FAST = 50;

        this.req;
        this.tetris = tetris;
        this.arena = tetris.arena;
        this.pieces = pieces;
        this.index = 0;
        this.dropCounter = 0;
        this.dropInterval = this.DROP_SLOW;
        this.pos = {x: 0, y: 0};
        this.matrix = null;
        this.score = 0;
        this.reset();
        this.paused = false;
        this.over = false;
    }

    drop()
    {
        this.pos.y++;
        if (this.arena.collide(this)) {
            this.pos.y--;
            this.arena.merge(this);
            this.index += 1;
            this.reset();
            this.score += this.arena.sweep();
            this.tetris.updateScore(this.score);
        }
        this.dropCounter = 0;
    }

    move(dir)
    {
        this.pos.x += dir;
        if (this.arena.collide(this)) {
            this.pos.x -= dir;
        }
    }

    reset()
    {
        this.matrix = createPiece(this.pieces[this.index]);
        this.pos.y = 0;
        this.pos.x = (this.arena.matrix[0].length / 2 | 0) -
                     (this.matrix[0].length / 2 | 0);
        if (this.arena.collide(this)){
            // this.arena.clear();
            // this.score = 0;
            // this.tetris.updateScore();
            this.over = true;
            // this.tetris.gameOver();
            return;
        }
    }

    rotate(dir)
    {
        const pos = this.pos.x;
        let offset = 1;
        this._rotateMatrix(this.matrix, dir);
        while (this.arena.collide(this)) {
            this.pos.x += offset;
            offset = -(offset + (offset > 0 ? 1 : -1));
            if (offset > this.matrix[0].length) {
                this._rotateMatrix(this.matrix, -dir);
                this.pos.x = pos;
                return;
            }
        }
    }

    _rotateMatrix(matrix, dir)
    {
        for (let y = 0; y < matrix.length; ++y) {
            for (let x = 0; x < y; ++x) {
                [
                    matrix[x][y],
                    matrix[y][x],
                ] = [
                    matrix[y][x],
                    matrix[x][y],
                ];
            }
        }

        if (dir > 0) {
            matrix.forEach(row => row.reverse());
        } else {
            matrix.reverse();
        }
    }

    update(deltaTime)
    {
        if(!this.paused){
            this.dropCounter += deltaTime;
            if (this.dropCounter > this.dropInterval) {
                this.drop();
            }
        }
    }

    pause(){
        if(!this.paused){
            this.paused = true;
        }
        else if(this.paused){
            this.paused = false;
        }
    }

    // reStart(){
    //     this.over = false;
    //     this.score = 0;
    //     this.tetris.updateScore(0);
    //     this.arena.clear();
    // }   
}
