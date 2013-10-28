# -*- coding: utf-8 -*-

require 'optparse'

$max_column_width = -1
$is_csv = false
opt = OptionParser.new
opt.on('-w WIDTH') do |width|
  $max_column_width = width.to_i
end
opt.on('--csv') do |width|
  $is_csv = true
end

opt.parse!(ARGV)

size_map = {}
lines = []

STDERR.reopen('/dev/null')

def jlength(str)
  all = str.length
  hankaku = str.scan(/[ -~]/u).size + str.scan(/[｡-ﾟ]/u).size
  all * 2 - hankaku
end

def split_line(line)
  unless $is_csv
    return line.split("\t")
  end
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
    len = jlength(item)
    if size_map.has_key?(i) then
      s = size_map[i]
      s = len if s < len
    else
      s = len
    end
    s = $max_column_width if $max_column_width > 0 && s > $max_column_width
    size_map[i] = s
  end
  lines.push(line)
end

def print_item(size_map, index, value)
  len = jlength(value)
  s = size_map[index] - len + 1
  s = 0 if s < 0
  print ' '
  print value
  print ' ' * s
end

print '|'
size_map.each_key do |i|
  print_item(size_map, i, (i + 1).to_s)
  print '|'
end
print "\n"

lines.each do |line|
  print '|'
  split_line(line).each_with_index do |item, i|
    print_item(size_map, i, item)
    print '|'
  end
  print "\n"
end

