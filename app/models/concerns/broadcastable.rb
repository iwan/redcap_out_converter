require 'active_support/concern'

module Broadcastable
  extend ActiveSupport::Concern

  included do
    # put here instance methods
    def start(t0)
      broadcast_append_to(self, partial: "processing/start", locals: { t0: t0 })
    end

    def info(t0, text)
      broadcast_append_to(self, partial: "processing/info", locals: { elapsed_time: elapsed_time(t0), text: text })
    end

    def error(t0, error)
      broadcast_append_to(self, partial: "processing/error", locals: { elapsed_time: elapsed_time(t0), error: error })
    end

    def finished(t0)
      broadcast_append_to(self, partial: "processing/finished", locals: { elapsed_time: elapsed_time(t0) })
    end

    def new_upload
      broadcast_append_to(self, target: "process-footer", partial: "processing/new_upload")
    end

    def remove_waiting_gif
      broadcast_remove_to(self, target: "wait")
    end

    has_one_attached :original_file
    has_one_attached :converted_file

    private

    def elapsed_time(t0)
      (Time.now-t0).round(1)
    end

  end

  class_methods do
    # put here class methods
    def class_meth
      puts "class_meth"
    end
  end
end
