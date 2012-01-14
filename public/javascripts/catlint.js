$(function(){

  /* Models & Collections */

  window.Morphism = Backbone.Model.extend({

    name: function() { return this.get("name"); },
    source: function() { return this.get("source"); },
    target: function() { return this.get("target"); }

  });

  window.MorphismCollection = Backbone.Collection.extend({
    
    model: Morphism,

    localStorage: new Store("morphisms"),

    comparator: function(f) { return f.name(); },

    objects: function() {
      return _.uniq(_.flatten(this.map(function(x) {
        return [x.source(), x.target()];
      })));
    },

    from: function() {
      return _(this.objects()).map(function(object) {
        return object;
      });
    },

    toDot: function() {
      var result = "digraph category { ";
      this.each(function(f) {
        result = result + "\"" + f.source() + "\" -> ";
        result = result + "\"" + f.target() + "\";";
      });
      result = result + " }";
      return result;
    },

    toGchartUrl: function() {
      var dotUrl = "http://chart.apis.google.com/chart?cht=gv:circo&chl=";
      return encodeURI(dotUrl + Morphisms.toDot());
    }

  });

  window.Morphisms = new MorphismCollection;

  window.Composition = Backbone.Model.extend({

    left: function() {
      return Morphisms.get(this.get("left_id"));
    },

    right: function() {
      return Morphisms.get(this.get("right_id"));
    },

    composite: function() {
      return Morphisms.get(this.get("composite_id"));
    }

  });

  window.CompositionCollection = Backbone.Collection.extend({

    model: Composition,

    localStorage: new Store("compositions")

  });

  window.Compositions = new CompositionCollection;

  /* Views */

  window.MorphismView = Backbone.View.extend({

    tagName: "li",

    template: _.template($("#morphism-template").html()),

    events: {
      "click .remove-morphism": "destroy"
    },

    initialize: function() {
      this.model.bind("change", this.render, this);
      this.model.bind("destroy", this.remove, this);
    },

    render: function() {
      $(this.el).html(this.template(this.model.toJSON()));
      return this;
    },

    destroy: function(event) {
      event.preventDefault();
      this.model.destroy();
    }

  });

  window.CompositionView = Backbone.View.extend({

    tagName: "li",

    template: _.template($("#composition-template").html()),

    initialize: function() {
      this.model.bind("change", this.render, this);
      this.model.bind("destroy", this.remove, this);
    },

    render: function() {
      $(this.el).html(this.template({c: this.model}));
      return this;
    }

  });

  window.AppView = Backbone.View.extend({

    el: $("#app"),

    statsTemplate: _.template($('#stats-template').html()),
    graphTemplate: _.template($('#graph-template').html()),

    events: {
      "click #add-morphism": "createMorphism"
    },

    initialize: function() {
      this.name = this.$("#hom_f");
      this.source = this.$("#hom_src");
      this.target = this.$("#hom_trg");

      Morphisms.bind("add", this.addMorphism, this);
      Morphisms.bind("all", this.render, this);

      Morphisms.fetch({add: true});
    },

    renderStats: function() {
      this.$("#stats").html(this.statsTemplate({
        objectsCount: Morphisms.objects().length,
        morphismsCount: Morphisms.length,
        compositionsCount: Compositions.length
      }));
      return this;
    },

    renderGraph: function() {
      // alert(Morphisms.toGchartUrl());
      this.$("#graph").html(this.graphTemplate({
        dot: Morphisms.toGchartUrl()
      }));
      return this;
    },

    render: function() {
      this.renderStats();
      this.renderGraph();
      return this;
    },

    addMorphism: function(morphism) {
      var view = new MorphismView({model: morphism});
      this.$("#morphisms").append(view.render().el);
    },

    addAll: function() {
      Morphisms.each(this.addMorphism);
    },

    createMorphism: function(event) {
      event.preventDefault();

      Morphisms.create({
        name: this.name.val(),
        source: this.source.val(),
        target: this.target.val()
      });

      this.name.val("");
      this.source.val("");
      this.target.val("");
    }

  });

  window.App = new AppView;

});

