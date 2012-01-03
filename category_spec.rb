require File.expand_path(File.dirname(__FILE__) + "/category")
Bundler.require(:default, :test)

describe "A category" do
  let(:ident) {{
    :home_business => :home_business_ident,
    :business => :business_ident,
    :residence => :residence_ident,
    :house => :house_ident,
  }}
  
  let(:hom) {{
    [:home_business, :home_business] => [:home_business_ident],
    [:business, :business] => [:business_ident],
    [:residence, :residence] => [:residence_ident],
    [:house, :house] => [:house_ident],
  
    [:home_business, :business] => [:home_business_is_a_business],
    [:home_business, :residence] => [:home_business_is_a_residence],
  
    [:business, :house] => [:business_is_a_house],
    [:residence, :house] => [:residence_is_a_house],
  
    [:home_business, :house] => [:home_business_is_a_business_house,
                                 :home_business_is_a_residence_house],
  }}
  
  let(:comp) {{
    [:home_business_ident, :home_business_ident] => :home_business_ident,
    [:business_ident, :business_ident] => :business_ident,
    [:residence_ident, :residence_ident] => :residence_ident,
    [:residence_ident, :residence_ident] => :residence_ident,
    [:house_ident, :house_ident] => :house_ident,
  
    [:home_business_is_a_business, :home_business_ident] => :home_business_is_a_business,
    [:business_ident, :home_business_is_a_business] => :home_business_is_a_business,
  
    [:home_business_is_a_residence, :home_business_ident] => :home_business_is_a_residence,
    [:residence_ident, :home_business_is_a_residence] => :home_business_is_a_residence,
  
    [:business_is_a_house, :business_ident] => :business_is_a_house,
    [:house_ident, :business_is_a_house] => :business_is_a_house,
  
    [:residence_is_a_house, :residence_ident] => :residence_is_a_house,
    [:house_ident, :residence_is_a_house] => :residence_is_a_house,
  
    [:home_business_is_a_business_house, :home_business_ident] => :home_business_is_a_business_house,
    [:house_ident, :home_business_is_a_business_house] => :home_business_is_a_business_house,
  
    [:home_business_is_a_residence_house, :home_business_ident] => :home_business_is_a_residence_house,
    [:house_ident, :home_business_is_a_residence_house] => :home_business_is_a_residence_house,
  
    [:business_is_a_house, :home_business_is_a_business] => :home_business_is_a_business_house,
    [:residence_is_a_house, :home_business_is_a_residence] => :home_business_is_a_residence_house,
  }}

  it "can be valid" do
    Category.new(ident, hom, comp)    
  end
end
