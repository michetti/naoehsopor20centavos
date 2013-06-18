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
    html = ""

    if this.data.descricao
      html += "<strong>Descrição:</strong><p>#{this.data.descricao}</p>"

    if this.data.sugestao
      html += "<br/>" if this.data.descricao
      html += "<strong>Sugestão:</strong><p>#{this.data.sugestao}</p>"

    blockquote = $("blockquote[data-ideia-id='#{this.data._id}']")

    blockquote.popover({
      placement: "top",
      trigger: "hover",
      html: true,
      content: html
    })

    blockquote.yellowFade()
    try
      FB.XFBML.parse(blockquote.get(0))
    catch e

  Template.itens.events({
    'click .votarIdeia': (e) ->
      e.preventDefault()
      Itens.update(this._id, {$inc: {votos: 1}})
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
          alert "Preencha pelo menos o título"
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
