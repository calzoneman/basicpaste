var assert = require('assert');
var fs = require('fs');

var Database = require('../lib/database');

try {
    fs.unlinkSync('test_db.sqlite');
} catch (e) {
}

describe('Database', function () {
    var db;

    beforeEach(function (done) {
        db = new Database({
            client: 'sqlite3',
            connection: { filename: 'test_db.sqlite' },
            pasteIdLength: 4
        });

        db.on('ready', done);
    });

    afterEach(function (done) {
        db = null;
        try {
            fs.unlinkSync('test_db.sqlite');
        } catch (e) {
        }
        done();
    });

    describe('#addPaste', function () {
        it('should add a paste', function (done) {
            var content = 'This is a test';

            db.addPaste(content, '127.0.0.1').then(function (paste) {
                assert.equal(paste.get('content'), content);
                assert.equal(paste.get('uploader_ip'), '127.0.0.1');
                done();
            });
        });
    });
});
