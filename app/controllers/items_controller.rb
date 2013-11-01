class ItemsController < ApplicationController
  # GET /items
  def index
    respond_to do |format|
      format.html { raise "Oops"}
      format.json {
        render :json => [ ]
      }
    end
  end

  # POST /items
  def create
    puts "Creating an item for #{params[:plan_id]} with title: #{params[:title]} \
details: #{params[:details]}"

    respond_to do |format|
      format.html { raise "Oops"}
      format.json {
        render :json => {
          :title => params[:title],
          :details => params[:details]
        }
      }
    end

  end
end
