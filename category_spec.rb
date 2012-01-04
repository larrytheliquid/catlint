require File.expand_path(File.dirname(__FILE__) + "/category")
Bundler.require(:default, :test)

describe "A category" do
  let(:ident) { Category.example_id }
  let(:hom) { Category.example_hom }
  let(:comp) { Category.example_comp }

  it "can be valid" do
    Category.new(ident, hom, comp)    
  end

  it "validates that hom keys are pairs" do
    hom[nil] = []

    lambda do
      Category.new(ident, hom, comp)
    end.should raise_error(/hom key must be a pair/i)
  end

  it "validates that hom values are arrays" do
    hom[[:residence, :residence]] = nil

    lambda do
      Category.new(ident, hom, comp)
    end.should raise_error(/hom value must be a pair/i)
  end

  it "validates that comp keys are pairs" do
    comp[nil] = :foo

    lambda do
      Category.new(ident, hom, comp)
    end.should raise_error(/comp key must be a pair/i)
  end

  it "validates that every object is unique" do
    # lambda do
      Category.new(ident, hom, comp)
    # end.should raise_error(/duplicate object/i)
  end

  it "validates that every arrow is unique" do
    hom[[:home_business, :residence]] = [:home_business_is_a_residence, :home_business_is_a_residence]

    lambda do
      Category.new(ident, hom, comp)
    end.should raise_error(/duplicate arrow/i)
  end

  it "validates that every identity is an arrow" do
    hom.delete [:residence, :residence]

    lambda do
      Category.new(ident, hom, comp)
    end.should raise_error(/identity not a morphism/i)
  end

  it "validates that every arrow has a source" do
    # lambda do
      Category.new(ident, hom, comp)
    # end.should raise_error(/arrow without source/i)
  end

  it "validates that every arrow has a target" do
    # lambda do
      Category.new(ident, hom, comp)
    # end.should raise_error(/arrow without target/i)
  end

  it "validates that the source of every arrow is an object" do
    hom[[:foo, :residence]] = [:bar]

    lambda do
      Category.new(ident, hom, comp)
    end.should raise_error(/source is not an object/i)
  end

  it "validates that the target of every arrow is an object" do
    hom[[:home_business, :foo]] = [:bar]

    lambda do
      Category.new(ident, hom, comp)
    end.should raise_error(/target is not an object/i)
  end

  it "validates that the source of every identity arrow is its object" do
    hom.delete [:residence, :residence]
    hom[[:business, :residence]] = [:residence_ident]

    lambda do
      Category.new(ident, hom, comp)
    end.should raise_error(/identity not an endomorphism/i)
  end

  it "validates that the target of every identity arrow is its object" do
    hom.delete [:residence, :residence]
    hom[[:residence, :business]] = [:residence_ident]

    lambda do
      Category.new(ident, hom, comp)
    end.should raise_error(/identity not an endomorphism/i)
  end

  it "validates that composition is not defined for uncomposable arrows" do
    comp[[:home_business_is_a_residence, :residence_is_a_house]] = :home_business_is_a_residence_house

    lambda do
      Category.new(ident, hom, comp)
    end.should raise_error(/composition of arrows that do not compose/i)
  end

  it "validates that composition is defined for all composable arrows" do
    comp.delete [:residence_is_a_house, :home_business_is_a_residence]

    lambda do
      Category.new(ident, hom, comp)
    end.should raise_error(/composition not defined/i)
  end

  it "validates that composition preserves sources" do
    comp[[:residence_is_a_house, :home_business_is_a_residence]] = :residence_is_a_house

    lambda do
      Category.new(ident, hom, comp)
    end.should raise_error(/composition source mismatch/i)
  end

  it "validates that composition preserves targets" do
    comp[[:residence_is_a_house, :home_business_is_a_residence]] = :home_business_is_a_business

    lambda do
      Category.new(ident, hom, comp)
    end.should raise_error(/composition target mismatch/i)
  end

  it "validates that the source identity law holds" do
    comp[[:home_business_is_a_residence_house, :home_business_ident]] = :home_business_is_a_business_house

    lambda do
      Category.new(ident, hom, comp)
    end.should raise_error(/source identity law/i)
  end

  it "validates that the target identity law holds" do
    comp[[:house_ident, :home_business_is_a_residence_house]] = :home_business_is_a_business_house

    lambda do
      Category.new(ident, hom, comp)
    end.should raise_error(/target identity law/i)
  end

  it "validates that the composition associativity law holds" do
    hom[[:residence, :residence]].push :residence_is_a_residence2
    hom[[:home_business, :residence]].push :home_business_is_a_residence2

    comp[[:residence_is_a_residence2, :residence_ident]] = :residence_is_a_residence2
    comp[[:residence_ident, :residence_is_a_residence2]] = :residence_is_a_residence2
    comp[[:home_business_is_a_residence2, :home_business_ident]] = :home_business_is_a_residence2
    comp[[:residence_ident, :home_business_is_a_residence2]] = :home_business_is_a_residence2

    comp[[:residence_is_a_house, :residence_is_a_residence2]] = :residence_is_a_house
    comp[[:residence_is_a_house, :home_business_is_a_residence2]] = :home_business_is_a_residence_house

    comp[[:residence_is_a_residence2, :residence_is_a_residence2]] = :residence_is_a_residence2
    comp[[:residence_is_a_residence2, :home_business_is_a_residence]] = :home_business_is_a_residence2
    comp[[:residence_is_a_residence2, :home_business_is_a_residence2]] = :home_business_is_a_residence

    lambda do
      Category.new(ident, hom, comp)
    end.should raise_error(/composition associativity law/i)
  end
end
