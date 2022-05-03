require 'csv'
# require 'awesome_print'

module RedcapExport

  class CsvReader
    attr_reader :feedback
    
    def initialize(object, t0=Time.now)
      @object   = object
      @t0       = t0
      @feedback = object.init_feedback

      @feedback.start(@t0)
    end
    
    
    def start
      @patient_column_idx  = @object.patient_col || 0
      @event_column_idx    = @object.event_col || 1
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
      content  = CSV.parse(@object.original_file.download, col_sep: "\t")
      @header  = content.shift
      @content = content.map do |row|
        key = row.values_at(@patient_column_idx, @event_column_idx)
        [key, row]
      end.to_h
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
      result.compact.uniq
    end
  end
end