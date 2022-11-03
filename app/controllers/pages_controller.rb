class PagesController < ApplicationController
  before_action :fit_session_page_ids, only: :show
  
  def new
    @page = Page.new
    # Page::STORED_ATTRIBUTES.each do |a|
    #   @page.write_attribute(a, session[a]) if session[a]
    # end
  end



  def create
    @page = Page.new page_params_on_create
    reader = CsvReader.new(@page).preread
    @page.set_auto_detection_attributes(reader)

    respond_to do |format|
      if @page.save
        session[:page_ids] ||= [] # array di valori interi
        session[:page_ids] << @page.id unless session[:page_ids][@page.id]
        # Page::STORED_ATTRIBUTES.each do |a|
        #   session[a] = page_params[a]
        # end
        format.html { redirect_to edit_page_path(@page), notice: "The file was successfully loaded." }
      else
        format.html { render :new }
      end
    end
  end

  def edit
    @page = Page.find params[:id]
    prepare_table
  end


  # PATCH /pages/:id
  def update
    @page = Page.find params[:id]
    respond_to do |format|
      if @page.update(page_params)
        prepare_table
        format.turbo_stream { render turbo_stream: turbo_stream.update('preview_table', partial: 'table') }
      end
    end
  end




  def show
    @page = Page.find_by id: params[:id]
    if @page && session[:page_ids]&.include?(@page.id)
      FileConverterJob.set(wait: 1.second).perform_later(@page) # if @page.completed_at.nil?
      puts "=====><<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
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
    def page_params_on_create
      params.require(:page).permit(:original_file)
    end

    def page_params
      params.require(:page).permit(:content_encoding, :rows_separator, :columns_separator, :patient_col, :event_col, :base_traits_identifier, :baseline_intervals, :follow_up_intervals, :header_row)
    end

    def prepare_table
      @reader = CsvReader.new(@page).preread(encoding: @page.content_encoding, row_sep: @page.rows_separator, col_sep: @page.columns_separator)
      if @reader[:result]==:ok
        @reader[:table].shift(@page.header_row) # throw the first n rows
        @header = @reader[:table].shift
      end
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
