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
      
      @slope, @offset = {}, {}
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
        sg  += g
        sb  += b
      end
      
      @slope[:r] = ( @size * srg - sr * sb ) / ( @size * srr - sr ** 2 ).to_f
      @slope[:g] = ( @size * sgb - sb * sg ) / ( @size * sgg - sb ** 2 ).to_f
      @slope[:b] = ( @size * sgb - sb * sg ) / ( @size * sbb - sg ** 2 ).to_f
    
      @offset[:r] = (sb - @slope[:r] * sr) / @size
      @offset[:g] = (sg - @slope[:g] * sb) / @size
      @offset[:b] = (sr - @slope[:b] * sg) / @size
      
      return
    end
  end
end
