Itens = new Meteor.Collection("itens")

Itens.allow
  insert: (userId, doc) ->
    yes

  update: (userId, doc, fields, modifier) ->
    fields.length == 2 and _.contains(fields, 'votos') and _.contains(fields, 'trending')

timeout = 60 * 60 * 1000

Meteor.startup ->
  console.log "Server iniciado"
  observe = false

  Itens.find({}).observeChanges
    added: (id, fields) ->
      return if not observe

      # set timeout for trending
      Meteor.setTimeout ->
        Itens.update(id, {$inc: {trending: -1}})
      , timeout

    changed: (id, fields) ->
      if observe and fields.votos
        # set timeout for trending
        Meteor.setTimeout ->
          Itens.update(id, {$inc: {trending: -1}})
        , timeout

  Itens.update {}, {$set: {trending: 0}}, {multi: true}, (error) ->
    console.log "Falha ao zerar trending: #{error}" if error
    observe = true
