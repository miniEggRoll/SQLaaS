fs      = require 'fs'
path    = require 'path'

fileExist = (pathname)->
    (done)->
        fs.exists pathname, (exists)->
            done null exists


module.exports = ->
    (next)->
        sqlID = @get 'sql-id'
        data = @request.query
        pathname = path.join __dirname, 'sql', sqlID, '.mustache'
        if sqlID and yield fileExist pathname
        
        yield next
