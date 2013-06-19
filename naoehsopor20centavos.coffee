Itens = new Meteor.Collection("itens")

if Meteor.isClient	
  $.fn.yellowFade = () ->
    this.animate( { backgroundColor: "#ffffcc" }, 1 ).animate( { backgroundColor: "#ffffff" }, 1500 )

  @remove = (id) ->
    Itens.remove(id)

  Template.itens.itens = () ->
    Itens.find({}, {sort: {votos: -1, titulo: 1}})

  Template.trends.itens = () ->
    Itens.find({trending: {$gt: 0}}, {sort: {trending: -1, titulo: 1}})

  Template.item.rendered = () ->
    blockquote = $("blockquote[data-ideia-id='#{this.data._id}']")
    blockquote.yellowFade()

  Template.item.events({
    'click .votarIdeia': (e) ->
      e.preventDefault()
      id = this._id
      key = "votou_#{id}"

      if Session.get(key) != true
        # update counters
        Itens.update(id, {$inc: {votos: 1, trending: 1}}, (error)->
          unless error
            # update sesison as voted
            Session.set(key, true)
        )
  })

  Template.trend.events({
    'click .votarIdeia': (e) ->
      e.preventDefault()
      id = this._id
      key = "votou_#{id}"

      if Session.get(key) != true
        # update counters
        Itens.update(id, {$inc: {votos: 1, trending: 1}}, (error)->
          unless error
            # update sesison as voted
            Session.set(key, true)
        )
  })

  Template.setup.rendered = ->
    if !window._gaq?
      window._gaq = []
      _gaq.push(['_setAccount', 'UA-41827878-1'])
      _gaq.push(['_trackPageview'])

      (->
        ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
        gajs = '.google-analytics.com/ga.js'
        ga.src = if 'https:' is document.location.protocol then 'https://ssl'+gajs else 'http://www'+gajs
        s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s)
      )()

  Meteor.startup( () ->
    $ ->
      $('#suaIdeiaModal').on 'shown', () ->
        $("#titulo").focus()

      $("#btnNovaIdeia").on "click", (e) ->
        $("#formNovaIdeia").submit()

      $("#formNovaIdeia").on "submit", (e) ->
        e.preventDefault()

        titulo = $("#titulo").val()
        descricao = $("#descricao").val()
        sugestao = $("#sugestao").val()

        if not titulo
          alert "Por favor, preencha o campo"
          $("#titulo").focus()
          return

        Itens.insert({titulo: titulo, descricao: descricao, sugestao: sugestao, votos: 1, trending: 1})

        $("#suaIdeiaModal").modal('hide')
        $("#formNovaIdeia")[0].reset()

        return
  )

if Meteor.isServer

  Meteor.startup( ()->
    console.log "Server iniciado"
    observe = false
    timeout = 60 * 60 * 1000

    Itens.find({}).observeChanges({
      added: (id, fields) ->
        if not observe
          return

        # set timeout for trending
        Meteor.setTimeout(->
          Itens.update(id, {$inc: {trending: -1}})
        , timeout)

      changed: (id, fields) ->
        if observe and fields.votos
          # set timeout for trending
          Meteor.setTimeout(->
            Itens.update(id, {$inc: {trending: -1}})
          , timeout)
    })

    Itens.update({}, {$set: {trending: 0}}, {multi: true}, (error)->
      if error
        console.log "Falha ao zerar trending: #{error}"

      observe = true
    )
  )
