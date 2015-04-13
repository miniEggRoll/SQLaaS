fs          = require 'fs'
Mustache    = require 'mustache'

module.exports = ->
    (next)->
        {template} = @request.body
        @sqlaas.create.template = template
        try
            parsed = Mustache.parse template if template
        catch e
            # bad template
        @sqlaas.create.valid = parsed?
        yield next
