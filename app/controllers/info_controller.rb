class InfoController < ApplicationController
  def about;
  end

  def terms_and_conditions;
    strings = ['The following text<C><B>is centred and in boldface</B></C>','<B>This <\g>is <B>boldface</B> in <<*> a</B> <\6> <<d>sentence','<B><C> This should be centred and in boldface, but the tags are wrongly nested </B></C>','<B>This should be in boldface, but there is an extra closing tag</B></C>','<B><C>This should be centred and in boldface, but there is a missing closing tag</C>']
    strings.each do |string|
      chars = string.split('')
      tags = []
      chars.each_with_index do |c, index|
        if c == "<" &&
          /[[:upper:]]/.match(chars[index+1]) &&
          chars[index+2] == '>'
          tags.push(chars[index+1])
        end
        if c == "<" &&
          chars[index+1] == '/'
          /[[:upper:]]/.match(chars[index+2]) &&
          chars[index+3] == '>'
          # this is an ending bracket, so check if the last html opening tag matches this, if not, throw error
          if chars[index+2] == tags.last
            tags.pop
          else
            puts "Expected </#{tags.last}> found #{c}#{chars[index+1]}#{chars[index+2]}#{chars[index+3]}"
            break
          end
        end
      end
    end
  end

  def privacy; end
end
