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
  
  def multiple_regression(dr, dg, db)
    regression = {}
    regression[:slope], regression[:offset] = {}, {}
    size = dr.size
    
    raise "arguments not same length!" unless size == dg.size && size == db.size
    
    if size == 1
      regression[:slope] = { :r => dr[0], :g => dg[0], :b => db[0] }
      regression[:offset] = { :r => 0, :g => 0, :b => 0 }
      return regression
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
      
    regression[:slope][:r] = ( size * srg - sr * sb ) / ( size * srr - sr ** 2 ).to_f
    regression[:slope][:g] = ( size * sgb - sb * sg ) / ( size * sgg - sb ** 2 ).to_f
    regression[:slope][:b] = ( size * sgb - sb * sg ) / ( size * sbb - sg ** 2 ).to_f
    
    regression[:offset][:r] = (sb - regression[:slope][:r] * sr) / size
    regression[:offset][:g] = (sg - regression[:slope][:g] * sb) / size
    regression[:offset][:b] = (sr - regression[:slope][:b] * sg) / size
    
    regression
  end
end
