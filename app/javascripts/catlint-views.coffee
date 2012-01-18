$ ->
  ### Views ###

  window.MorphismView = Backbone.View.extend
    tagName: "li"
    template: _.template $("#morphism-template").html()

    events:
      "click .remove-morphism": "destroy"

    initialize: ->
      @model.bind "change",  @render, @
      @model.bind "destroy", @remove, @

    render: ->
      $(@el).html @template @model.toJSON()
      @

    destroy: (event) ->
      event.preventDefault()
      @model.destroy()

  window.CompositionView = Backbone.View.extend
    tagName: "li"
    template: _.template $("#composition-template").html()

    initialize: ->
      @model.bind "change", @render, @
      @model.bind "destroy", @remove, @

    render: ->
      $(@el).html @template c: @model
      @

  window.AppView = Backbone.View.extend
    el: $("#app")

    validationTemplate: _.template $("#validation-template").html()
    navTemplate:        _.template $("#nav-template").html()
    graphTemplate:      _.template $("#graph-template").html()

    events:
      "click #add-morphism": "createMorphism"

    initialize: ->
      @name   = @$("#morphism-name input")
      @source = @$("#morphism-source input")
      @target = @$("#morphism-target input")

      Morphisms.bind    "all", @render, @
      Compositions.bind "all", @render, @
      Morphisms.bind    "add", @renderValid, @
      Morphisms.bind    "add", @addMorphism, @
      Compositions.bind "add", @addComposition, @

      Morphisms.fetch    add: true
      Compositions.fetch add: true
      Morphisms.bind     "add", Compositions.define, Compositions

    clearInvalid: ->
      @$("#validation").fadeOut()
      @$("#right .error").removeClass "error"
      @$("#morphisms span.morphism").addClass "primary"

    renderValid: ->
      @clearInvalid()
      @name.val    ""
      @source.val  ""
      @target.val  ""
      @

    renderInvalid: (view) ->
      (model, error) ->
        view.clearInvalid()
        view.renderGraph error.model
        view.$("#validation").html view.validationTemplate
          message: error.message
        view.$("#validation").fadeIn()
        view.$(error.selector).removeClass("primary").addClass("error")
        view

    renderNav: ->
      @$("#nav").html @navTemplate
        objectsCount:      Morphisms.objects().length
        morphismsCount:    Morphisms.length
        compositionsCount: Compositions.length
      @

    renderGraph: (invalidMorphism) ->
      @$("#graph").html @graphTemplate
        dot: Morphisms.toGchartUrl invalidMorphism
      @

    render: ->
      @renderNav()
      @renderGraph()
      @

    addMorphism: (morphism) ->
      view = new MorphismView model: morphism
      @$("#morphisms").append view.render().el

    addComposition: (composition) ->
      view = new CompositionView model: composition
      @$("#compositions").append view.render().el

    createMorphism: (event) ->
      valid = Morphisms.create
        name:   @name.val()
        source: @source.val()
        target: @target.val()
        { error: @renderInvalid @ }

  window.App = new AppView
