class ItemsController < ApplicationController
  # GET /plans/:plan_id/items
  def show
    respond_to do |format|
      format.html { raise "Oops"}
      format.json {
        render :json => [ ]
      }
    end
  end

  # POST /plans/:plan_id/items
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
