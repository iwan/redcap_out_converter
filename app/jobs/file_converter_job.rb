class FileConverterJob < ApplicationJob
  queue_as :default

  class FileConverterError < StandardError
  end

  # discard_on FileConverterError
  discard_on Exception

  def perform(page)
    begin
      t0 = Time.now
      reader = ::RedcapExport::CsvReader.new(page, t0)
      reader.start
      reader.parse

    rescue Exception => e
      # puts e.inspect
      reader.feedback.error(t0, e)
      raise e # StandardError.new()

    ensure
      reader.feedback.new_upload
      reader.feedback.remove_waiting_gif
      reader.feedback.completed!
    end
  end
end
