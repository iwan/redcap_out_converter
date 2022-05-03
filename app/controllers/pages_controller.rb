class PagesController < ApplicationController
  before_action :fit_session_page_ids, only: :show
  
  def new
    @page = Page.new
    Page::STORED_ATTRIBUTES.each do |a|
      @page.write_attribute(a, session[a])
    end
    @page.patient_col = 0 if @page.patient_col.blank?
    @page.event_col = 1 if @page.event_col.blank?
  end

  def create
    @page = Page.new page_params
    respond_to do |format|
      if @page.save
        session[:page_ids] ||= []
        session[:page_ids] << @page.id
        Page::STORED_ATTRIBUTES.each do |a|
          session[a] = page_params[a]
        end
        format.html { redirect_to @page, notice: "The file was successfully loaded." }
      else
        format.html { render :new }
      end
    end
  end

  def show
    @page = Page.find_by id: params[:id]
    if @page && session[:page_ids]&.include?(@page.id)
      FileConverterJob.set(wait: 1.second).perform_later(@page) if @page.completed_at.nil?
    else
      redirect_to new_page_path, alert: "Sorry the page was not found."
    end
  end


  def destroy
    @page = Page.find_by id: params[:id]
    if @page && session[:page_ids]&.include?(@page.id)
      @page&.destroy
    end
    respond_to do |format|
      format.html { redirect_to new_page_url, notice: "The files were successfully deleted." }
    end
  end



  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def page_params
      params.require(:page).permit(:original_file, :patient_col, :event_col, :base_traits_identifier, :baseline_intervals, :follow_up_intervals)
    end

    def print_page_ids
      puts "session[:page_ids]: #{session[:page_ids].inspect}"  
    end
    
    def fit_session_page_ids
      puts session[:page_ids].inspect
      session[:page_ids] = Page.where(id: session[:page_ids]).pluck(:id)      
      puts session[:page_ids].inspect
    end
end
