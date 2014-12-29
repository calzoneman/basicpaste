bookshelf = require 'bookshelf'
knex = require 'knex'
crypto = require 'crypto'
{ EventEmitter } = require 'events'

class Database extends EventEmitter
    constructor: (@config) ->
        @knex = knex(@config)
        @bookshelf = bookshelf(@knex)
        @ready = false
        
        @knex.schema.hasTable('pastes').then( (exists) =>
            if !exists
                console.log('Creating table pastes')
                @knex.schema.createTable('pastes', (t) ->
                    t.increments('id').primary()
                    t.string('paste_id', 16).unique()
                    t.string('uploader_ip', 39).index()
                    t.text('content')
                    t.timestamps()
                )
            else
                true
        ).then( =>
            @ready = true
            @emit('ready')
        ).catch( (err) ->
            console.error('Database initialization failed: %s', err)
        )

        @Paste = @bookshelf.Model.extend(
            tableName: 'pastes'
            hasTimestamps: true
        )

    addPaste: (content, ip) ->
        idLength = @config.pasteIdLength
        pasteId = crypto.pseudoRandomBytes(idLength).toString('base64')
        pasteId = pasteId.substring(0, idLength).replace(/\//g, '_')

        new @Paste(
            paste_id: pasteId,
            content: content,
            uploader_ip: ip
        ).save().tap( (paste) ->
            console.log('Added paste: id=%d uploader_ip=%s paste_id=%s',
                paste.get('id'), paste.get('uploader_ip'), pasteId)
        ).catch( (err) ->
            console.error('Error adding paste: %s', err)
            throw err
        )

module.exports = Database
