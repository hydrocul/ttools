# -*- coding: utf-8 -*-

require 'optparse'

$max_column_width = -1
opt = OptionParser.new

opt.parse!(ARGV)

def split_line(line)
  ret = []
  col = ""
  len = line.length
  is_quoted = false
  is_prequote = false
  len.times do |i|
    ch = line[i]
    if is_prequote
      if ch == "\""
        is_prequote = false
        col = col + ch
      elsif ch == ","
        is_quoted = false
        is_prequote = false
        ret.push(col)
        col = ""
      else
        is_prequote = false
        col = col + "\"" + ch
      end
    elsif is_quoted
      if ch == "\""
        is_prequote = true
      else
        col = col + ch
      end
    else
      if ch == ","
        ret.push(col)
        col = ""
      elsif col.length == 0 && ch == "\""
        is_quoted = true
      else
        col = col + ch
      end
    end
  end
  ret.push(col)
  return ret
end

while line = STDIN.gets
  if /^(.*)$/ =~ line then
    line = $1
  end
  split_line(line).each_with_index do |item, i|
    print "\t" if i > 0
    print item
  end
  print "\n"
end


