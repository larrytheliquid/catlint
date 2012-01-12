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

    template: _.template($("#morphism-template").html()),

    events: {
      "click .remove-morphism": "destroy",
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
    },

  });

  window.AppView = Backbone.View.extend({

    el: $("#app"),

    statsTemplate: _.template($('#stats-template').html()),

    events: {
      "click #add-morphism": "createMorphism",
    },

    initialize: function() {
      this.name = this.$("#hom_f");
      this.source = this.$("#hom_src");
      this.target = this.$("#hom_trg");

      Morphisms.bind("add", this.addMorphism, this);
      Morphisms.bind("all", this.render, this);

      Morphisms.fetch({add: true});
    },

    render: function() {
      this.$("#stats").html(this.statsTemplate({
        morphismsCount: Morphisms.length,
      }));
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
        target: this.target.val(),
      });

      this.name.val("");
      this.source.val("");
      this.target.val("");
    },

  });

  window.App = new AppView;

});

