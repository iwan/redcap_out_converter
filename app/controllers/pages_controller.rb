class PagesController < ApplicationController
  # before_action :print_page_ids
  
  def new
  end

  def create
    @page = Page.new page_params
    respond_to do |format|
      if @page.save
        session[:page_ids] ||= []
        session[:page_ids] << @page.id
        format.html { redirect_to @page, notice: "The file was successfully loaded." }
      else
        format.html { render :new }
      end
    end
  end

  def show
    @page = Page.find_by id: params[:id]
    if @page && session[:page_ids]&.include?(@page.id)
      FileConverterJob.set(wait: 1.second).perform_later @page
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
      params.require(:page).permit(:original_file)
    end

    def print_page_ids
      puts "session[:page_ids]: #{session[:page_ids].inspect}"  
    end
end
