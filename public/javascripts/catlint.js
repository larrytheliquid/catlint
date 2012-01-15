$(function(){

  /* Models & Collections */

  window.Morphism = Backbone.Model.extend({

    name: function() { return this.get("name"); },
    source: function() { return this.get("source"); },
    target: function() { return this.get("target"); },

    validate: function(attrs) {

      if (!attrs.name) {
        return {
          selector: "#morphism-name",
          message: "morphism name is required"
        };
      }

      var existingMorphism = attrs.name && Morphisms.byName(attrs.name);
      if (existingMorphism) {
        return {
          selector: "#morphism-name, #morphisms span:contains('" + attrs.name + "')",
          message: "morphism '" + attrs.name + "' already exists",
          model: existingMorphism
        };
      }

      if (!attrs.source) {
        return {
          selector: "#morphism-source",
          message: "morphism source is required"
        };
      }

      if (!attrs.target) {
        return {
          selector: "#morphism-target",
          message: "morphism target is required"
        };
      }

    }

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

    byName: function(name) {
      return this.find(function(f) {
        return f.name() == name;
      });
    },

    toDot: function(invalidMorphism) {
      var result = "digraph category { ";
      this.each(function(f) {
        result = result + "\"" + f.source() + "\" -> ";
        result = result + "\"" + f.target() + "\"";
        if (f == invalidMorphism) {
          result = result + "[color=\"red\"]";
        }
        result = result + ";";
      });
      result = result + " }";
      return result;
    },

    toGchartUrl: function(invalidMorphism) {
      var dotUrl = "http://chart.apis.google.com/chart?cht=gv:circo&chl=";
      return encodeURI(dotUrl + Morphisms.toDot(invalidMorphism));
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

    validationTemplate: _.template($('#validation-template').html()),
    statsTemplate: _.template($('#stats-template').html()),
    graphTemplate: _.template($('#graph-template').html()),

    events: {
      "click #add-morphism": "createMorphism"
    },

    initialize: function() {
      this.name = this.$("#morphism-name input");
      this.source = this.$("#morphism-source input");
      this.target = this.$("#morphism-target input");

      Morphisms.bind("all", this.render, this);
      Morphisms.bind("add", this.renderValid, this);
      Morphisms.bind("add", this.addMorphism, this);

      Morphisms.fetch({add: true});
    },

    clearInvalid: function() {
      this.$("#validation").fadeOut();
      this.$("#right .error").removeClass("error");
      this.$("#morphisms span.morphism").addClass("primary");
    },

    renderValid: function() {
      this.clearInvalid();
      this.name.val("");
      this.source.val("");
      this.target.val("");
      return this;
    },

    renderInvalid: function(view) {
      return function(model, error) {
        view.clearInvalid();
        view.renderGraph(error.model);
        view.$("#validation").html(view.validationTemplate({
          message: error.message
        }));
        view.$("#validation").fadeIn();
        view.$(error.selector).removeClass("primary").addClass("error");
        return view;
      };
    },

    renderStats: function() {
      this.$("#stats").html(this.statsTemplate({
        objectsCount: Morphisms.objects().length,
        morphismsCount: Morphisms.length,
        compositionsCount: Compositions.length
      }));
      return this;
    },

    renderGraph: function(invalidMorphism) {
      this.$("#graph").html(this.graphTemplate({
        dot: Morphisms.toGchartUrl(invalidMorphism)
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

      var valid = Morphisms.create({
        name: this.name.val(),
        source: this.source.val(),
        target: this.target.val()
      }, {
        error: this.renderInvalid(this)
      });
    }

  });

  window.App = new AppView;

});

