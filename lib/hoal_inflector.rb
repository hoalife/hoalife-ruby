# frozen_string_literal: true

# Inflector to support the HOAL style of
# spelling HOALife
class HOALInflector < Zeitwerk::Inflector
  def camelize(basename, _abspath)
    case basename
    when 'ccr_article'
      'CCRArticle'
    when 'hoalife'
      'HOALife'
    when /Error/
      'Error'
    else
      super
    end
  end
end
