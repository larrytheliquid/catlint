// Put your application scripts here
$(document).ready(function(){
  function removeEquation (event){
    event.preventDefault();
    $(this).parent().remove();
  }

  $(".remove-equation").click(removeEquation);

  $(".add-morphism").click(function(event){
    event.preventDefault();
    var morphism = $("#morphisms .equation").first().clone();
    morphism.find("input").attr("value", "");
    morphism.click(removeEquation);
    $("#morphisms").append(morphism);
  });

  $(".add-comp").click(function(event){
    event.preventDefault();
    var morphism = $("#comp .equation").first().clone();
    morphism.find("input").attr("value", "");
    $("#comp").append(morphism);
  });
});
