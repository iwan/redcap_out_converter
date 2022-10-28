require 'csv'
require 'charlock_holmes'
# require 'awesome_print'

module RedcapExport

  class CsvReader
    attr_reader :feedback

    ROWS_SEP = { cr: "\r", lf: "\n", crlf: "\r\n" }
    COLS_SEP = { tab: "\t", comma: ",", semicolon: ";" }

    def initialize(object, t0=Time.now)
      @object   = object
      @t0       = t0
      @feedback = object.init_feedback

      @feedback.start(@t0)
    end
    
    
    def start
      @patient_column_idx  = (@object.patient_col || 1)-1
      @event_column_idx    = (@object.event_col || 2)-1
      @base_traits_id      = @object.base_traits_identifier # what's the label for the baseline?

      @base_intervals      = decode_intervals(@object.baseline_intervals)
      @follow_up_intervals = decode_intervals(@object.follow_up_intervals)

      read

      @feedback.info(@t0, "CSV readed")
      
      @patients_label   = @header[@patient_column_idx]
      @baseline_labels  = @header.values_at(*@base_intervals)
      @follow_up_labels = @header.values_at(*@follow_up_intervals)

      @bl_no            = @baseline_labels.size
      @fu_no            = @follow_up_labels.size
      @traits_no        = @bl_no + @fu_no

      @patients     = @content.keys.map{|row| row[@patient_column_idx]}.uniq.sort # list of patients
      @events       = @content.keys.map{|row| row[@event_column_idx]}.uniq - [@base_traits_id] # list of events names except baseline
    end


    def parse(options={}, &block)
      row_sep = options.fetch(:row_sep, "\n")
      col_sep = options.fetch(:col_sep, "\t")
      sleep(0.8)
      @feedback.info(@t0, "Parsing...")
      sleep(1.2)


      str = CSV.generate(row_sep: row_sep, col_sep: col_sep) do |csv|
        # --- header
        row = [@patients_label]
        row += @baseline_labels
        @events.each do |event|
          row += @follow_up_labels.map{|e| block_given? ? yield(event, e) : "#{event}/#{e}"}
        end
        csv << row

        # --- values
        @patients.sort.each do |patient|
          row = []
          row << patient
          # baseline
          row += @content.fetch([patient, @base_traits_id], Array.new(@traits_no, nil)).values_at(*@base_intervals) if @base_traits_id
          # followups
          @events.each do |fu|
            row += @content.fetch([patient, fu], Array.new(@traits_no, nil)).values_at(*@follow_up_intervals)
          end
          csv << row
        end
      end

      # File.open("./output.csv", 'w') { |file| file.write(str) }
      # https://mikerogers.io/2019/09/06/storing-a-string-in-active-storage
      @object.converted_file.attach(
        io: StringIO.new(str),
        filename: 'output.csv',
        content_type: 'text/csv'
      )

      @feedback.finished(@t0)

      # @object.info("Comversion successfully completed!", t0: @t0)
      # path = Rails.application.routes.url_helpers.rails_blob_path(@object.converted_file, only_path: true)
      # @object.info("<a href='#{path}' target='_blank'>Download here</a>", t0: @t0)
    end


    private



    def read
      # https://stackoverflow.com/questions/48749767/rails-read-csv-file-data-with-active-storage
      file_content = @object.original_file.download
      detector = CharlockHolmes::EncodingDetector.new
      detection = detector.detect(file_content)
      utf8_encoded_content = CharlockHolmes::Converter.convert file_content, detection[:encoding], 'UTF-8'
      options = detect_rows_and_columns_separators(utf8_encoded_content)
      @feedback.info(@t0, "Text encoding: #{detection[:encoding]} (confidence: #{detection[:confidence]}%)")
      @feedback.info(@t0, "Row separator: #{options[:row_sep].inspect}, column separator: #{options[:col_sep].inspect}")

      content  = CSV.parse(utf8_encoded_content, **options)
      # content  = CSV.parse(@object.original_file.download, col_sep: "\t")
      @header  = content.shift
      @content = content.map do |row|
        key = row.values_at(@patient_column_idx, @event_column_idx)
        [key, row]
      end.to_h
    end

    def detect_rows_and_columns_separators(content)
      result = {}
      sep = detect_rows_sep(content)
      if sep != :unknown
        result[:row_sep] = ROWS_SEP[sep]

        sep = detect_cols_sep(sep, content)
        if sep # not nil
          result[:col_sep] = COLS_SEP[sep]
        end
      end
      result
    end

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
      mean = arr.sum(0.0) / arr.size
      sum = arr.sum(0.0) { |element| (element - mean) ** 2 }
      variance = sum / (arr.size - 1)
      [mean, Math.sqrt(variance)]
    end

    def detect_cols_sep(rows_sep, content)
      res = COLS_SEP.transform_values{|v| mean_and_standard_deviation content.split(ROWS_SEP[rows_sep]).map{|row| row.split(v).size}}
      # {:tab=>[20.0, 0.0], :comma=>[1.0, 0.0], :semicolon=>[1.0, 0.0]}
      @feedback.info(@t0, res.inspect)

      max_mean = 0.0
      candidate = nil
      res.each_pair do |sp, values|
        mean, stdev = values
        if mean>max_mean
          max_mean = mean
          candidate = sp
          # if stdev<0.5 # soglia arbitraria
          #   candidate = sp
          # end
        end
      end
      candidate
    end




    def decode_intervals(string)
      result = []
      string.gsub(/[^0-9\,\-]/, "").split(',').each do |tok|
        a2 = tok.split("-")

        if a2.size==1
          result << a2[0].to_i
        else
          result += (a2[0]..a2[1]).to_a.map(&:to_i)
        end
      end
      result.compact.uniq.map{|n| n-1}
    end
  end
end