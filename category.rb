class Category
  Error = Class.new StandardError

  def initialize(id, hom, comp)
    @id, @hom, @comp = id.freeze, hom.freeze, comp.freeze

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

    validate_comp_composable
    validate_comp_defined_for_arrows
    validate_comp_preserves_sources_and_targets

    validate_identity_laws
    validate_associativity_law
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

  def to_dot
    fontsize = 8
    result = "digraph category {"
    result << "\n  node [fontsize=#{fontsize}];"
    arrows.each do |f|
      result << "\n  \"#{src(f)}\" -> \"#{trg(f)}\" [label=\"#{f}\", fontsize=#{fontsize}];"
    end
    result << "\n}"
    result
  end

  private

  def validate_syntax
    @hom.keys.each do |k|
      unless k.kind_of?(Array) && k.size == 2
        raise Error, "hom key must be a pair"
      end
    end

    @hom.values.each do |v|
      unless v.kind_of?(Array)
        raise Error, "hom value must be a pair"
      end
    end

    @comp.keys.each do |k|
      unless k.kind_of?(Array) && k.size == 2
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

  def validate_comp_defined_for_arrows
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

end
