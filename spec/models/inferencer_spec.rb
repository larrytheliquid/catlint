require 'spec_helper'

describe "A partially defined category" do
  let(:hom) {{
      [:home_business, :business] => [:home_business_is_a_business],
      [:home_business, :residence] => [:home_business_is_a_residence],
      [:business, :house] => [:business_is_a_house],
      [:residence, :house] => [:residence_is_a_house],
      
      [:home_business, :house] => [:home_business_is_a_business_house,
                                   :home_business_is_a_residence_house],
    }}

  let(:comp) {{
      [:business_is_a_house, :home_business_is_a_business] => :home_business_is_a_business_house,
      [:residence_is_a_house, :home_business_is_a_residence] => :home_business_is_a_residence_house,
    }}

  it "can have its remaining bits inferred" do
    Category.infer(hom, comp)
  end
end
