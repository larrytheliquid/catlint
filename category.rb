class Category

  def initialize(id, hom, comp)
    @id, @hom, @comp = id.freeze, hom.freeze, comp.freeze

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

    validate_comp_defined_for_arrows
    validate_comp_composable
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

  private

  def validate_unique_objects
    unless objects.size == objects.uniq.size
      raise "duplicate object"
    end
  end

  def validate_unique_arrows
    unless arrows.size == arrows.uniq.size
      raise "arrow with duplicate source or target"
    end
  end

  def validate_identities_are_arrows
    objects.each do |x|
      unless arrows.include? id(x)
        raise "identity not a morphism"
      end
    end
  end

  def validate_arrows_have_sources_and_targets
    arrows.each do |f|
      unless @src.key?(f)
        raise "arrow without source"
      end

      unless @trg.key?(f)
        raise "arrow without target"
      end
    end
  end

  def validate_sources_and_targets_are_objects
    arrows.each do |f|
      unless objects.include? src(f)
        raise "source is not an object"
      end

      unless objects.include? trg(f)
        raise "target is not an object"
      end
    end
  end

  def validate_identities_are_endomorphisms
    objects.each do |x|
      unless src(id(x)) == x
        raise "identity not an endomorphism"
      end

      unless trg(id(x)) == x
        raise "identity not an endomorphism"
      end
    end
  end

  def validate_comp_defined_for_arrows
    arrows.each do |f|
      from(trg(f)).each do |g|
        unless @comp.key? [g, f]
          desc = "\n#{g} . #{f}"
          raise "composition not defined:#{desc}"
        end
      end
    end
  end

  def validate_comp_composable
    @comp.each do |(g, f), gof|
      unless src(g) == trg(f)
        desc =  "\n#{g} . #{f}"
        desc << "\nsrc(#{g}) = #{src(g)}"
        desc << "\ntrg(#{f}) = #{trg(f)}"
        raise "composition not composable:#{desc}"
      end
    end
  end

  def validate_comp_preserves_sources_and_targets
    @comp.each do |(g, f), gof|
      unless src(gof) == src(f)
        raise "composition source mismatch"
      end

      unless trg(gof) == trg(g)
        raise "composition target mismatch"
      end
    end
  end

  def validate_identity_laws
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
