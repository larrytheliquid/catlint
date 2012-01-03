class Category

  def initialize(id, hom, comp)
    @id, @hom, @comp = id.freeze, hom.freeze, comp.freeze
    validate_unique_arrows

    @src, @trg = {}, {}
    @hom.each do |(x, y), arrs|
      arrs.each do |arr|
        @src[arr] = x
        @trg[arr] = y
      end
    end
    @src.freeze
    @trg.freeze

    validate_comp_defined_for_hom
    validate_comp_domain
    validate_identity_law
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

  private

  def validate_unique_arrows
    unless arrows.size == arrows.uniq.size
      raise "arrow with duplicate source or target"
    end
  end

  def validate_comp_domain
    @comp.each do |(g, f), arr|
      unless src(g) == trg(f)
        
        desc =  "\n#{g} . #{f}"
        desc << "\nsrc(#{g}) = #{src(g)}"
        desc << "\ntrg(#{f}) = #{trg(f)}"
        raise "composition type mismatch:#{desc}"
      end

      unless src(arr) == src(f)
        raise "composition source mismatch"
      end
      
      unless trg(arr) == trg(g)
        raise "composition target mismatch"
      end
    end
  end

  def validate_comp_defined_for_hom
    arrows.each do |f|
      from(trg(f)).each do |g|
        unless @comp.key? [g, f]
          desc = "\n#{g} . #{f}"
          raise "composition not defined:#{desc}"
        end
      end
    end
  end

  def validate_identity_law
    arrows.each do |arr|
      unless comp( arr, id(src(arr)) ) == arr
        raise "identity law"
      end

      unless comp( id(trg(arr)), arr ) == arr
        raise "identity law"
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
            raise "composition associativity law:#{desc}"
          end
        end
      end
    end
  end

end
