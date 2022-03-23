class FileConverterJob < ApplicationJob
  queue_as :default

  class FileConverterError < StandardError
  end

  discard_on FileConverterError

  def perform(page)
    begin
      t0 = Time.now
      reader = ::RedcapExport::CsvReader.new(page, t0)
      reader.parse

    rescue Exception => e
      page.error(t0, e)
      raise FileConverterError.new()

    ensure
      page.new_upload
      page.remove_waiting_gif
    end
  end
end
