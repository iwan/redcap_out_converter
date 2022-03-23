require 'csv'
# require 'awesome_print'

module RedcapExport

  class CsvReader
    def initialize(object, t0=Time.now)
      @object   = object
      @t0       = t0

      @subject_column = 0
      @visit_column = 1
  
      @object.start(@t0)


      read
      @object.info(@t0, "CSV readed")

      @subjects  = @content.keys.map{|row| row[@subject_column]}.uniq
      @max_visit = @content.keys.map{|row| row[@visit_column].to_i}.max

      @repeated_head = @header[2..-1]
      @repeated_size = @repeated_head.size

      # ap @content 
    end


    def parse
      row_sep = "\n"
      col_sep = "\t"
      sleep(1.2)
      @object.info(@t0, "Parsing...")
      sleep(2.3)


      str = CSV.generate(row_sep: row_sep, col_sep: col_sep) do |csv|
        row = [@header[0]]
        1.upto(@max_visit) do |n|
          row += @repeated_head.map{|e| "#{e}_#{n}"}
        end
        csv << row

        @subjects.sort.each do |subject|
          row = []
          row << subject
          1.upto(@max_visit) do |n|
            row += @content.fetch([subject, n.to_s], Array.new(@repeated_size, nil))
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

      @object.finished(@t0)

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
        key = row.shift(2)
        [key, row]
      end.to_h
    end
  end
end