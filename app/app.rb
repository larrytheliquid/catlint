class Catlint < Padrino::Application
  register SassInitializer
  register Padrino::Rendering
  register Padrino::Helpers

  enable :sessions

  HIDDEN_PATH = '96A77B38-6E2E-419F-9EC8-BFBA91BBDCC0'

  get :/ do
    File.read(Padrino.root + "/public/index.html")
  end

  get :validator, :map => HIDDEN_PATH do
    @category = Category.example
    @id, @hom, @comp = @category.to_json_options
    render :validator
  end

  post :validator, :map => HIDDEN_PATH do
    @id, @hom, @comp = params[:id], params[:hom], params[:comp]

    begin
      @category = Category.parse_json_options @id, @hom, @comp
    rescue Category::Error => e
      @error = e.message.gsub("\n", "<br/>")
    end

    render :validator
  end
end
