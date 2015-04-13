path            = require 'path'
koa             = require 'koa'
body            = require 'koa-parse-json'
serve = require 'koa-static'
# acl             = require(path.join(__dirname, 'acl'))
# templateValidation  = require(path.join(__dirname, 'templateValidation'))
# sqlCompiler     = require(path.join(__dirname, 'sqlCompiler'))
# queryHandler    = require(path.join(__dirname, 'queryHandler'))
router        = require(path.join(__dirname, 'router'))

app = koa()
app.use serve path.join(__dirname, '../../node_modules/')
app.use body()
app.use (next)->
    @sqlaas = 
        create: {}
        read: {}
        update: {}
        remove: {}
        exec: {}

    yield next
# app.use acl ''
# app.use templateValidation ''
# app.use sqlCompiler ''
# app.use queryHandler ''
router app

app.listen '8080'
