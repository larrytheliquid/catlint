$(function(){

  window.Morphism = Backbone.Model.extend({});

  window.MorphismCollection = Backbone.Collection.extend({
    
    model: Morphism,

    localStorage: new Store("morphisms"),

    comparator: function(morphism) {
      return morphism.get("name");
    },

  });

  window.Morphisms = new MorphismCollection;

  window.MorphismView = Backbone.View.extend({

    tagName: "li",

    // template: _.template($("#morphism-template").html()),

    initialize: function() {
      this.model.bind("change", this.render, this);
    },

    render: function() {
      // $(this.el).html(this.template(this.model.toJSON()));
      $(this.el).html("foo");
      return this;
    },

  });

  window.AppView = Backbone.View.extend({

    el: $("#right"),

    events: {
      "click #add-morphism": "createMorphism",
    },

    initialize: function() {
      this.name = this.$("#hom_f");
      this.source = this.$("#hom_src");
      this.target = this.$("#hom_trg");

      Morphisms.bind("add", this.addMorphism, this);
    },

    addMorphism: function(morphism) {
      var view = new MorphismView({model: morphism});
      this.$("#morphisms").append(view.render().el);
    },

    createMorphism: function(event) {
      event.preventDefault();

      Morphisms.create({
        name: this.name.val(),
        source: this.source.val(),
        target: this.target.val(),
      });

      this.name.val("");
      this.source.val("");
      this.target.val("");
    },

  });

  window.App = new AppView;

});

