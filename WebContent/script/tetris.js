class Tetris
{
    constructor(element)
    {
        this.element = element;
        this.canvas = element.querySelector('canvas');
        this.context = this.canvas.getContext('2d');
        this.context.scale(20, 20);
        this.arena = new Arena(12, 20);
        this.player = new Player(this);
        this.req = null;

        this.colors = [
            null,
            '#FF0D72',
            '#0DC2FF',
            '#0DFF72',
            '#F538FF',
            '#FF8E0D',
            '#FFE138',
            '#3877FF',
        ];

        let lastTime = 0;
        const update = (time = 0) => {
            if(this.player.over){
                this.gameOver();
                return;
            }
            else{
                this.req = requestAnimationFrame(update);
                const deltaTime = time - lastTime;
                lastTime = time;
                this.player.update(deltaTime);
                this.draw();
            }
        };
        update();
        this.updateScore(0);
    }

    draw()
    {
        this.context.fillStyle = '#000';
        this.context.fillRect(0, 0, this.canvas.width, this.canvas.height);

        this.drawMatrix(this.arena.matrix, {x: 0, y: 0});
        this.drawMatrix(this.player.matrix, this.player.pos);
    }

    drawMatrix(matrix, offset)
    {
        matrix.forEach((row, y) => {
            row.forEach((value, x) => {
                if (value !== 0) {
                    this.context.fillStyle = this.colors[value];
                    this.context.fillRect(x + offset.x,
                                     y + offset.y,
                                     1, 1);
                }
            });
        });
    }

    updateScore(score)
    {
        this.element.querySelector('.score').innerText = score;
    }

    gameOver(){
        cancelAnimationFrame(this.req);
        this.context.font="2px Comic Sans MS";
        this.context.fillStyle="#ffffff";
        this.context.textAlign="center";
        this.context.textBaseline="middle";
        this.context.fillText("Game Over",(this.canvas.width/20)/2,(this.canvas.width/20)/2);
        document.getElementById("start_game").disabled=false;
    }

    // restart(){
    //     this.context.clearRect(0,0,this.canvas.width,this.canvas.height);
    // }
}