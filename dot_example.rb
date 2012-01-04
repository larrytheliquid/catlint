require File.expand_path(File.dirname(__FILE__) + "/category")

cat = Category.new Category.example_id, Category.example_hom, Category.example_comp
puts cat.to_dot
