require 'paleta/version'
require 'paleta/color'
require 'paleta/palette'

module Paleta
  class MissingDependencyError < StandardError; end

  @rmagick_available = begin
    require "rmagick"
  rescue LoadError
    false
  end

  def self.rmagick_available?
    @rmagick_available
  end
end
