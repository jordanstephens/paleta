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
  
  def multiple_regression(dx, dy, dz)
    regression = {}
    regression[:slope], regression[:offset] = {}, {}
    size = dx.size
    
    raise "arguments not same length!" unless size == dy.size && size == dz.size
    
    if size == 1
      regression[:slope] = { :x => dx[0], :y => dy[0], :z => dz[0] }
      regression[:offset] = { :x => 0, :y => 0, :z => 0 }
      return regression
    end
    
    sxx = syy = szz = sxy = szx = syz = sx = sy = sz = 0
    dx.zip(dy, dz).each do |x, y, z|
      sxx += x ** 2
      syy += y ** 2
      sxy += x * y
      szx += z * x
      syz += y * z
      sx  += x
      sy  += y
      sz  += z
    end
      
    regression[:slope][:x] = ( size * sxy - sx * sz ) / ( size * sxx - sx ** 2 ).to_f
    regression[:slope][:y] = ( size * syz - sz * sy ) / ( size * syy - sz ** 2 ).to_f
    regression[:slope][:z] = ( size * syz - sz * sy ) / ( size * szz - sy ** 2 ).to_f
    
    regression[:offset][:x] = (sz - regression[:slope][:x] * sx) / size
    regression[:offset][:y] = (sy - regression[:slope][:y] * sz) / size
    regression[:offset][:z] = (sx - regression[:slope][:z] * sy) / size
    
    regression
  end
end
