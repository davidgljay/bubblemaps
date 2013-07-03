module PostsHelper

  def linkify(text)
    array = text.split(' ')
    array.each_with_index do |word, i|
      if word.first(7) == 'http://' || word.first(4) == 'www.'
        array[i] = "<a href='#{word}', target = '_blank'>#{word}</a>"
      end
    end
    array * ' '
  end


end
