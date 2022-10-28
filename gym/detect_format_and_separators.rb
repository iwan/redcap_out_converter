
require 'charlock_holmes'

list = [
  "file_utf8_cr_tab.csv",
  "file_utf8_lf_tab.csv",
  "file_utf8_crlf_tab.csv",
  "file_latin1_cr_tab.csv",
  "file_latin1_lf_tab.csv",
  "file_latin1_crlf_tab.csv",
  "file_utf16le_cr_tab.csv",
  "file_utf16le_lf_tab.csv",
  "file_utf16le_crlf_tab.csv"
]

ROWS_SEP = { cr: "\r", lf: "\n", crlf: "\r\n" }
COLS_SEP = { tab: "\t", comma: ",", semicolon: ";" }

def count_rows_sep(content)
  ROWS_SEP.transform_values{|v| content.split(v).size}
end

def detect_rows_sep(content)
  rows_count = count_rows_sep(content)
  threshold = 7
  cr_vs_lf = 100*(rows_count[:cr]-rows_count[:lf]).abs.to_f/[rows_count[:cr],rows_count[:lf]].max
  if (cr_vs_lf<=threshold)
    :crlf
  elsif (cr_vs_lf>=(100-threshold))
    if(rows_count[:cr]>rows_count[:lf])
      :cr
    else
      :lf
    end
  else
    :unknown
  end
end

def mean_and_standard_deviation(arr)
  puts arr.inspect
  mean = arr.sum(0.0) / arr.size
  sum = arr.sum(0.0) { |element| (element - mean) ** 2 }
  variance = sum / (arr.size - 1)
  [mean, Math.sqrt(variance)]
end

def detect_cols_sep(rows_sep, content)
  res = COLS_SEP.transform_values{|v| mean_and_standard_deviation content.split(ROWS_SEP[rows_sep]).map{|row| row.split(v).size}}
  # {:tab=>[20.0, 0.0], :comma=>[1.0, 0.0], :semicolon=>[1.0, 0.0]}

  max_mean = 0.0
  candidate = nil
  res.each_pair do |sep, values|
    mean, stdev = values
    if mean>max_mean
      max_mean = mean
      if stdev<0.5 # soglia arbitraria
        candidate = sep
      end
    end
  end
  puts res.inspect
  candidate
end


detector = CharlockHolmes::EncodingDetector.new

list.each do |file|
  puts "reading #{file}..."
  content = File.read(file)
  detection = detector.detect(content)
  # puts detection.inspect
  # begin
  #   puts detect_rows_sep(content)
  # rescue StandardError => e
  #   puts "Error!!!"
  # end
  puts "... encoding to utf8"
  utf8_encoded_content = CharlockHolmes::Converter.convert content, detection[:encoding], 'UTF-8'

  rows_sep = detect_rows_sep(utf8_encoded_content) # usa questo!
  cols_sep = detect_cols_sep(rows_sep, utf8_encoded_content)
  puts rows_sep
  puts cols_sep

  puts "\n"
end






