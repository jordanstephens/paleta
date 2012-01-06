module Math
  def distance(a, b)
    unless (a.is_a?(Hash) && b.is_a?(Hash) && a.keys == b.keys) || (a.is_a?(Array) && b.is_a?(Array) && a.size == b.size)
      raise ArgumentError, "Arguments must be Hashes with identical keys or Arrays of the same size"
    end
    sum = 0
    a.keys.each { |k| sum += (a[k] - b[k]) ** 2 } if a.is_a?(Hash)
    a.each_with_index { |v, i| sum += (a[i] - b[i]) ** 2 } if a.is_a?(Array)
    sqrt(sum)
  end
  
  class MultipleRegression
    attr_accessor :slope, :offset

    def initialize dr, dg, db
    
      @size = dr.size
      raise "arguments not same length!" unless @size == dg.size && @size == db.size
    
      if @size == 1
        @slope = { :r => dr[0], :g => dg[0], :b => db[0] }
        @offset = { :r => 0, :g => 0, :b => 0 }
        return
      end
    
      srr = sgg = sbb = srg = sbr = sgb = sr = sb = sg = 0
      dr.zip(dg,db).each do |r,g,b|
        srr += r ** 2
        sgg += g ** 2
        srg += r * g
        sbr += b * r
        sgb += g * b
        sr  += r
        sb  += g
        sg  += b
      end
    
      slope_rg = ( @size * srg - sr * sb ) / ( @size * srr - sr ** 2 ).to_f
      slope_gb = ( @size * sgb - sb * sg ) / ( @size * sgg - sb ** 2 ).to_f
      slope_br = ( @size * sgb - sb * sg ) / ( @size * sbb - sg ** 2 ).to_f
    
      offset_rg = (sb - slope_rg * sr) / @size
      offset_gb = (sg - slope_gb * sb) / @size
      offset_br = (sr - slope_br * sg) / @size
    
      @slope = { :r => slope_rg, :g => slope_gb, :b => slope_br }
      @offset = { :r => offset_rg, :g => offset_gb, :b => offset_br }
      return
    end
  end
end
