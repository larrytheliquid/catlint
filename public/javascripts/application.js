// Put your application scripts here
$(document).ready(function(){
  $(".remove-equation").click(function(event){
    event.preventDefault();
    $(this).parent().remove();
  });

  $(".add-morphism").click(function(event){
    event.preventDefault();
    morphism = $("#morphisms .equation:first").clone();
    morphism.find("input").attr("value", "");
    $("#morphisms").append(morphism);
  });

  $(".add-comp").click(function(event){
    event.preventDefault();
    morphism = $("#comp .equation:first").clone();
    morphism.find("input").attr("value", "");
    $("#comp").append(morphism);
  });
});
