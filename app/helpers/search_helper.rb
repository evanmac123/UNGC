module SearchHelper
  def format(result)
    response = result.excerpts.content
    response.gsub!('&amp;nbsp;', ' ')
    response.gsub!(/&amp;gt(;)?/, '>')
    response.gsub!(/&amp;(n|m)dash;/, '-')
    response
  end
end