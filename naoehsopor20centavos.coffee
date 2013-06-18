Itens = new Meteor.Collection("itens")

@convertToSlug = (url) ->
  slug = url.toLowerCase()
  slug = slug.replace /[^\w-]+/g,'_'

if Meteor.isClient	
  $.fn.yellowFade = () ->
    this.animate( { backgroundColor: "#ffffcc" }, 1 ).animate( { backgroundColor: "#ffffff" }, 1500 )

  @remove = (id) ->
    Itens.remove(id)

  Template.itens.itens = () ->
    Itens.find({}, {sort: {votos: -1, titulo: 1}})

  Template.item.helpers {
    slug: (url)->
      convertToSlug(url)
  }

  Template.item.rendered = () ->
    blockquote = $("blockquote[data-ideia-id='#{this.data._id}']")

    blockquote.yellowFade()

    try
      FB.XFBML.parse(blockquote.get(0))
    catch e

  Template.itens.events({
    'click .votarIdeia': (e) ->
      e.preventDefault()
      id = this._id
      key = "votou_#{id}"

      if Session.get(key) != true
        Itens.update(id, {$inc: {votos: 1}})
        Session.set(key, true)
      else
        alert "Apenas 1 voto por proposta é aceito"

    'click .detalhesButton': (e) ->
      e.preventDefault()
      id = this._id
      key = "detalhe_visivel_#{id}"
      blockquote = $("blockquote[data-ideia-id='#{id}']")

      if Session.get(key) == true
        $(".detalhesButton", blockquote).html("Mostrar Detalhes")
        $(".detalhes", blockquote).addClass("hidden")
        Session.set(key, false)
      else
        $(".detalhesButton", blockquote).html("Esconder Detalhes")
        $(".detalhes", blockquote).removeClass("hidden")
        Session.set(key, true)
  })

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
          alert "Por favor, preencha o título"
          $("#titulo").focus()
          return

        Itens.insert({titulo: titulo, descricao: descricao, sugestao: sugestao, votos: 1})

        $("#suaIdeiaModal").modal('hide')
        $("#formNovaIdeia")[0].reset()

        return
  )

if Meteor.isServer
  Meteor.startup( ()->
    console.log "Server iniciado"
  )
