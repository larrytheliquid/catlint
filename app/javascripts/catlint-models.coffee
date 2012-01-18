$ ->
  ### Models ###

  window.Morphism = Backbone.Model.extend
    name:   -> @get "name"
    source: -> @get "source"
    target: -> @get "target"

    composable: -> Morphisms.from @target()

    validate: (attrs) ->
      existingMorphism = Morphisms.byName attrs.name if attrs.name

      if not attrs.name
        selector: "#morphism-name"
        message:  "morphism name is required"

      else if existingMorphism
        selector: "#morphism-name, #morphisms span:contains('#{attrs.name}')"
        message:  "morphism '#{attrs.name}' already exists"
        model:    existingMorphism

      else if not attrs.source
        selector: "#morphism-source"
        message:  "morphism source is required"

      else if not attrs.target
        selector: "#morphism-target"
        message:  "morphism target is required"

  window.Composition = Backbone.Model.extend
    left:      -> Morphisms.get @get "leftId"
    right:     -> Morphisms.get @get "rightId"
    composite: -> Morphisms.get @get "compositeId"

  ### Collections ###

  window.MorphismCollection = Backbone.Collection.extend
    model:        Morphism
    localStorage: new Store "morphisms"
    comparator:   (f) -> f.name()

    objects: ->
      _.uniq _.flatten @map (x) -> [x.source(), x.target()]

    from: (x) ->
      @filter (f) -> x is f.source()

    composites: (g, f) ->
      @filter (gof) ->
        gof.target() is g.target() and gof.source() is f.source()

    byName: (name) ->
      @find (f) -> f.name() is name

    toDot: (invalidMorphism) ->
      result = "digraph category { "
      @each (f) ->
        result += "\"#{f.source()}\" -> "
        result += "\"#{f.target()}\""
        if f is invalidMorphism
          result += " [color=\"red\"]"
        result += "; "
      result += "}"
      result

    toGchartUrl: (invalidMorphism) ->
      dotUrl = "http://chart.apis.google.com/chart?cht=gv:circo&chl="
      encodeURI (dotUrl + Morphisms.toDot invalidMorphism)

  window.Morphisms = new MorphismCollection

  window.CompositionCollection = Backbone.Collection.extend
    model:        Composition
    localStorage: new Store "compositions"

    byMorphisms: (g, f) ->
      @find (gof) -> g is gof.left() and f is gof.right()

    define: () ->
      Morphisms.each (f) =>
        _.each f.composable(), (g) =>
          existingComposition = @byMorphisms g, f
          composites = Morphisms.composites g, f

          if not existingComposition
            if composites.length is 1
              Compositions.create
                leftId:      g.id
                rightId:     f.id
                compositeId: composites[0].id
            else
              Compositions.create
                leftId:      g.id
                rightId:     f.id

          else if not existingComposition.composite() and composites.length is 1
            existingComposition.save compositeId: composites[0].id

  window.Compositions = new CompositionCollection
