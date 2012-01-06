require 'spec_helper'

describe "the home page" do
  before { visit "/" }

  it "displays a cat image successfully" do
    page.should have_selector("body img")
  end
end

describe "the category validator" do
  before { visit "/#{Catlint::HIDDEN_PATH}" }

  it "displays successfully" do
    page.should have_content("Category Validator")
  end

  it "validates a valid category" do
    click_on "Validate"
    page.should have_selector(".alert-message.success")
  end

  %w[id hom comp].each do |option|
    it "displays a validation error for an invalid #{option}" do
      fill_in option, :with => "foo"
      click_on "Validate"
      page.should have_selector(".alert-message.error")
    end
  end
end
