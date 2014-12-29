var config = {
    db: {
        client: 'sqlite3',
        connection: {
            filename: 'paste.sqlite'
        },
        pasteIdLength: 4
    },
    
    listen: [
        ['', 5000]
    ],

    uploadSizeLimit: '100kb'
};

(function () {
    var fs = require('fs');
    if (fs.existsSync('config.js')) {
        require('./config')(config);
    }
})();

var Database = require('./lib/database');
var Webserver = require('./lib/web');

var db = new Database(config.db);
var server = new Webserver(config, db);
