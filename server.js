var exec = require('child_process').exec,
    express = require('express'),
    app = express(),
    http = require('http').Server(app),
    io = require('socket.io')(http),
    fs = require('fs'),
    getPixels = require("get-pixels"),
    args = process.argv.slice(2),
    fifo = fs.createWriteStream(args[0]),
    width = args[1].split('x')[0], height = args[1].split('x')[1],
    cmdOpenChrome = 'open -a "Google Chrome" http://localhost:3000?size='+args[1];

app.use("/", express.static(process.cwd() + '/client'));

http.listen(3000, function(){
    exec(cmdOpenChrome, function() {
        io.on('connection', function(socket){

            socket.on('greetings', function(data){
                socket.emit('nextFrame', true);
            });

            socket.on('newFrame', function(frame){
                getPixels(frame.png, function(err, pixels) {
                    if(err) {
                        console.log("Error - image invalid.")
                        return
                    }
                    fifo.write( new Buffer( (pixels.data)), function(){ 
                        socket.emit('nextFrame', true); 
                    });
                });
            });

            socket.on('disconnect', function(msg){
                console.log("done.");
                process.exit();
            });
        });
    });
});
