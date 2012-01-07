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
    @hom = @category.hom_without_id
    @comp = @category.comp_without_id

    render :validator
  end

  post :validator, :map => HIDDEN_PATH do
    @hom, @comp = {}, {}

    params[:hom_f].each_with_index do |f, i|
      @hom[[params[:hom_src][i], params[:hom_trg][i]]] ||= []
      @hom[[params[:hom_src][i], params[:hom_trg][i]]] << f
    end

    params[:comp_gof].each_with_index do |gof, i|
      @comp[[params[:comp_g][i], params[:comp_f][i]]] = gof
    end

    begin
      @category = Category.infer @hom, @comp
    rescue Category::Error => e
      @error = e.message.gsub("\n", "<br/>")
    end

    render :validator
  end
end
