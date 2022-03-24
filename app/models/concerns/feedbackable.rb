require 'active_support/concern'

module Feedbackable
  extend ActiveSupport::Concern

  class Feedback
    def initialize(obj)
      @object = obj
      @object.update(completed_at: nil)
    end
    
    def start(t0)
      @object.broadcast_append_to(@object, partial: "processing/start", locals: { t0: t0 })
    end
    
    def info(t0, text)
      @object.broadcast_append_to(@object, partial: "processing/info", locals: { elapsed_time: elapsed_time(t0), text: text })
    end
    
    def error(t0, error)
      @object.broadcast_append_to(@object, partial: "processing/error", locals: { elapsed_time: elapsed_time(t0), error: error })
    end
    
    def finished(t0)
      @object.broadcast_append_to(@object, partial: "processing/finished", locals: { elapsed_time: elapsed_time(t0) })
    end
    
    def new_upload
      @object.broadcast_append_to(@object, target: "process-footer", partial: "processing/new_upload")
    end
    
    def remove_waiting_gif
      @object.broadcast_remove_to(@object, target: "wait")
    end
    
    def completed!
      @object.update(completed_at: Time.now)
    end
    
    private
    
    def elapsed_time(t0)
      (Time.now-t0).round(1)
    end
  end
  
  
  included do
    def init_feedback
      Feedback.new(self)
    end
        
    has_one_attached :original_file
    has_one_attached :converted_file
  end
end
