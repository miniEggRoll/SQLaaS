_           = require 'underscore'
co          = require 'co'
fs          = require 'fs'
path        = require 'path'
router      = require 'koa-trie-router'
uuid        = require 'node-uuid'
mysql       = require 'mysql'
Mustache    = require 'mustache'
Entities    = new require('html-entities').XmlEntities
index       = fs.readFileSync path.join(__dirname, 'view/index.mustache'), {encoding: 'utf8'}

entities = new Entities()

pool = mysql.createPool {
    host: '192.168.99.100'
    user: 'root'
    password: 'mysql'
}

write = (pathname, text)->
    (done)->
        fs.writeFile pathname, text, (err)->
            done err, err?

readFile = (filename)->
    pathname = path.join "#{__dirname}/sql", filename
    (done)->
        fs.readFile pathname, {encoding: 'utf8'}, (err, template)->
            done err if err
            id = path.basename filename, '.mustache'
            done null, {id, template}

readdir = (dirname)->
    (done)->
        fs.readdir dirname, done

render = (ctx)->
    Mustache.render index, ctx

execQuery = (sqlID, query)->
    (done)->
        co ->
            {template} = yield readFile "#{sqlID}.mustache"
            test = _.chain(query)
            .map (q, key)-> [key, mysql.escape q]
            .object()
            .value()

            escape = entities.decode Mustache.render(template, test)
            pool.query escape, (err, rows, fields)->
                if err? then done err else done null, rows.map (r)-> {json: JSON.stringify r}
        .catch done

module.exports = (app)->
    app.use router app

    app.route(['/', '/sql'])
    .get (next)->
        fileNames = yield readdir path.join(__dirname, 'sql')
        list = yield fileNames.map readFile
        sql = []
        @body = render {list, sql}
        yield next

    app.route('/sql/:sqlID')
    .get (next)->
        {sqlID} = @params
        fileNames = yield readdir path.join(__dirname, 'sql')
        list = yield fileNames.map readFile
        sql = _.filter list, ({id})->
            id is sqlID
        @body = render {list, sql}
        yield next

    app.route('/sql')
    .put (next)->
        {valid, template} = @sqlaas.create
        if valid
            sqlID = uuid.v1()
            pathname = path.join __dirname, 'sql', sqlID, '.mustache'
            yield write pathname, template
            @status = 200
            list = yield readdir path.join(__dirname, 'sql')
            sql = [{template, sqlID}]
            @body = render {list, sql}
        yield next

    app.route('/exec/:sqlID')
    .get (next)->
        {sqlID} = @params
        fileNames = yield readdir path.join(__dirname, 'sql')
        list = yield fileNames.map readFile
        sql = _.findWhere list, {id: sqlID}
        exec = if sql? then yield execQuery(sqlID, @query) else []
        @body = render {list, sql:[sql], exec}
        yield next        
