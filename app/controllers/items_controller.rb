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
          :id => 102,
          :title => params[:title],
          :details => params[:details]
        }
      }
    end
  end

  # DELETE /items/:id
  def destroy
    puts "Deleting item with id: #{params[:id]}"
    respond_to do |format|
      format.html { raise "Oops"}
      format.json { head :no_content }
    end
  end

  # GET /suggest
  def suggest
    suggestions = [ ]

    case params[:type]
    when "tag"
      suggestions << {
        :type => "tag",
        :value => "food"
      }
      suggestions << {
        :type => "tag",
        :value => "restaurant"
      }
    when "location"
      suggestions = GooglePlace.suggest(params[:term])
    else
      raise "Unknown suggestion type..."
    end

    respond_to do |format|
      format.html { raise "Oops"}
      format.json {
        render :json => { :suggestions => suggestions }
      }
    end
  end
end
