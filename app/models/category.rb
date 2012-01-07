class Category
  SEPARATOR = ":"
  Error = Class.new StandardError

  def initialize(opts)
    @id, @hom, @comp = parse_options opts
    validate_syntax

    @src, @trg = {}, {}
    @hom.each do |(x, y), arrs|
      arrs.each do |arr|
        @src[arr] = x
        @trg[arr] = y
      end
    end
    @src.freeze
    @trg.freeze

    validate_unique_objects
    validate_unique_arrows
    validate_identities_are_arrows

    validate_arrows_have_sources_and_targets
    validate_sources_and_targets_are_objects
    validate_identities_are_endomorphisms

    validate_comp_defined_with_arrows
    validate_comp_composable
    validate_comp_defined_for_composable_arrows
    validate_comp_preserves_sources_and_targets

    validate_identity_laws
    validate_associativity_law
  end

  def self.infer(hom, comp)
    objects = hom.keys.flatten.uniq

    id = {}
    objects.each do |x|
      idx = "#{x}_ident".to_sym
      id[x] = idx
      hom[[x, x]] ||= []
      hom[[x, x]].push idx
    end

    hom.each do |(x, y), fs|
      fs.each do |f|
        comp[[f, id[x]]] = f
        comp[[id[y], f]] = f
      end
    end

    new :id => id, :hom => hom, :comp => comp
  end

  def objects() @objects ||= @id.keys end
  def arrows() @arrows ||= @hom.values.flatten end
  def id(obj) @id.fetch obj end
  def hom(x, y) @hom[[x, y]] || [] end
  def comp(g, f) @comp.fetch [g, f] end
  def src(f) @src.fetch f end
  def trg(f) @trg.fetch f end

  def from(x)
    objects.map do |y|
      hom(x, y)
    end.flatten
  end

  def to_hash
    {:id => @id, :hom => @hom, :comp => @comp}
  end

  def to_json_options
    id_json = @id
    hom_json = {}
    comp_json = {}

    @hom.each do |k, v|
      hom_json[k.join(SEPARATOR)] = v
    end

    @comp.each do |k, v|
      comp_json[k.join(SEPARATOR)] = v
    end

    [id_json.to_json, hom_json.to_json, comp_json.to_json]
  end

  def self.parse_json_options(id_json, hom_json, comp_json)
    if id_json.empty?
      raise Error, "identity function JSON empty"
    end

    if hom_json.empty?
      raise Error, "hom set relation JSON empty"
    end

    if comp_json.empty?
      raise Error, "composition function JSON empty"
    end

    begin
      id = JSON.parse id_json
    rescue JSON::ParserError => e
      raise Error, "invalid identity function JSON"
    end

    begin
      hom = JSON.parse hom_json
      hom.keys.each do |k|
        hom[k.split(SEPARATOR)] = hom.delete(k)
      end
    rescue JSON::ParserError => e
      raise Error, "invalid hom set relation JSON"
    end

    begin
      comp = JSON.parse comp_json
      comp.keys.each do |k|
        comp[k.split(SEPARATOR)] = comp.delete(k)
      end
    rescue JSON::ParserError => e
      raise Error, "invalid composition function JSON"
    end

    new :id => id, :hom => hom, :comp => comp
  end

  def to_dot
    result = "digraph category {"
    arrows.each do |f|
      result << "\n  \"#{src(f)}\" -> \"#{trg(f)}\";"
    end
    result << "\n}"
    result
  end

  def to_dot_param
    URI.escape to_dot
  end

  def to_gchart_url
    "http://chart.apis.google.com/chart?cht=gv:circo&chl=#{to_dot_param}"
  end

  private

  def parse_options(opts)
    unless opts.key? :id
      raise Error, "options must include identity function 'id'"
    end

    unless opts.key? :hom
      raise Error, "options must include hom relation 'hom'"
    end

    unless opts.key? :comp
      raise Error, "options must include composition function 'comp'"
    end

    extras = opts.keys - [:id, :hom, :comp]
    unless extras.empty?
      desc = "\n#{extras.first}"
      raise Error, "extraneous options disalowed:#{desc}"
    end

    [opts[:id].freeze, opts[:hom].freeze, opts[:comp].freeze]
  end

  def validate_syntax
    @hom.keys.each do |k|
      unless k.kind_of?(Enumerable) && k.count == 2
        desc = "\n#{k}"
        raise Error, "hom key must be a pair:#{desc}"
      end
    end

    @hom.values.each do |v|
      unless v.kind_of?(Enumerable)
        raise Error, "hom value must be a list"
      end
    end

    @comp.keys.each do |k|
      unless k.kind_of?(Enumerable) && k.count == 2
        raise Error, "comp key must be a pair"
      end
    end
  end

  def validate_unique_objects
    unless objects.size == objects.uniq.size
      raise Error, "duplicate object"
    end
  end

  # TODO: unique identities?

  def validate_unique_arrows
    unless arrows.size == arrows.uniq.size
      raise Error, "duplicate arrow"
    end
  end

  def validate_identities_are_arrows
    objects.each do |x|
      unless arrows.include? id(x)
        desc = "\n#{id(x)}"
        raise Error, "identity not a morphism:#{desc}"
      end
    end
  end

  def validate_arrows_have_sources_and_targets
    arrows.each do |f|
      unless @src.key?(f)
        raise Error, "arrow without source"
      end

      unless @trg.key?(f)
        raise Error, "arrow without target"
      end
    end
  end

  def validate_sources_and_targets_are_objects
    arrows.each do |f|
      unless objects.include? src(f)
        desc = "\nsrc(#{f}) = #{src(f)}"
        raise Error, "source is not an object:#{desc}"
      end

      unless objects.include? trg(f)
        desc = "\ntrg(#{f}) = #{trg(f)}"
        raise Error, "target is not an object:#{desc}"
      end
    end
  end

  def validate_identities_are_endomorphisms
    objects.each do |x|
      unless src(id(x)) == x
        desc =  "\nid(#{x}) = #{id(x)}"
        desc << "\nsrc(id(#{x})) = #{src(id(x))}"
        raise Error, "identity not an endomorphism:#{desc}"
      end

      unless trg(id(x)) == x
        desc =  "\nid(#{x}) = #{id(x)}"
        desc << "\ntrg(id(#{x})) = #{trg(id(x))}"
        raise Error, "identity not an endomorphism:#{desc}"
      end
    end
  end

  def validate_comp_defined_with_arrows
    @comp.each do |(g, f), gof|
      desc = "\n#{g} . #{f} = #{gof}"

      unless arrows.include? g
        raise Error, "left composite not an arrow:#{desc}"
      end

      unless arrows.include? f
        raise Error, "right composite not an arrow:#{desc}"
      end

      unless arrows.include? gof
        raise Error, "composite result not an arrow:#{desc}"
      end
    end
  end

  def validate_comp_composable
    @comp.each do |(g, f), gof|
      unless src(g) == trg(f)
        desc =  "\n#{g} . #{f}"
        desc << "\nsrc(#{g}) = #{src(g)}"
        desc << "\ntrg(#{f}) = #{trg(f)}"
        raise Error, "composition of arrows that do not compose:#{desc}"
      end
    end
  end

  def validate_comp_defined_for_composable_arrows
    arrows.each do |f|
      from(trg(f)).each do |g|
        unless @comp.key? [g, f]
          desc = "\n#{g} . #{f}"
          raise Error, "composition not defined:#{desc}"
        end
      end
    end
  end

  def validate_comp_preserves_sources_and_targets
    @comp.each do |(g, f), gof|
      unless src(gof) == src(f)
        raise Error, "composition source mismatch"
      end

      unless trg(gof) == trg(g)
        raise Error, "composition target mismatch"
      end
    end
  end

  def validate_identity_laws
    arrows.each do |arr|
      unless comp( arr, id(src(arr)) ) == arr
        raise Error, "source identity law"
      end

      unless comp( id(trg(arr)), arr ) == arr
        raise Error, "target identity law"
      end
    end
  end

  def validate_associativity_law
    arrows.each do |f|
      from(trg(f)).each do |g|
        from(trg(g)).each do |h|
          unless comp( comp(h, g), f) == comp(h, comp(g, f))
            desc =  "\n#{g} . #{f} = #{comp(g, f)}"
            desc << "\n#{h} . #{g} = #{comp(h, g)}"
            desc << "\n(#{h} . #{g}) . #{f} = #{comp( comp(h, g), f)}"
            desc << "\n#{h} . (#{g} . #{f}) = #{comp( h, comp(g, f) )}"
            raise Error, "composition associativity law:#{desc}"
          end
        end
      end
    end
  end

  public

  def self.example_id
    {
      :home_business => :home_business_ident,
      :business => :business_ident,
      :residence => :residence_ident,
      :house => :house_ident,
    }
  end

  def self.example_hom
    {
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
    }
  end

  def self.example_comp
    {
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
    }
  end

  def self.example_options
    {:id => example_id, :hom => example_hom, :comp => example_comp}
  end

  def self.example
    new example_options
  end

end
