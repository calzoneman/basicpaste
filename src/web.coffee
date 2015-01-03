express = require 'express'
path = require 'path'

class Webserver
    constructor: (@config, @db) ->
        @app = express()
        
        @app.use(require('body-parser').urlencoded(
            limit: @config.uploadSizeLimit
            extended: false
        ))

        @app.get('/', (req, res) ->
            res.sendFile(path.resolve(__dirname, '..', 'public', 'index.html'))
        )

        @app.post('/paste', (req, res) =>
            content = req.body.content

            if not content
                return res.status(400).send('No paste content submitted')

            @db.addPaste(content, req.ip).then( (paste) ->
                res.redirect(paste.get('paste_id'))
            ).catch( (err) ->
                res.status(500).send(err.message)
            )
        )

        @app.get('/:id', (req, res) =>
            id = req.params.id.replace(/[^\w+_]/g, '')
            new @db.Paste(paste_id: id).fetch(require: true).then( (paste) ->
                res.type('text').send(paste.get('content'))
            ).catch(@db.Paste.NotFoundError, (err) ->
                res.status(404).send("No paste for id #{id}")
            ).catch( (err) ->
                res.status(500).send(err.message)
            )
        )

        @config.listen.forEach( (pair) =>
            [host, port] = pair
            server = @app.listen(port, host)
            server.on('error', (err) ->
                console.error("Failed to bind #{host}:#{port}: #{err}")
            )
            server.on('listening', ->
                console.log("Listening on #{host}:#{port}")
            )
        )

module.exports = Webserver
