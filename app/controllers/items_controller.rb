class ItemsController < ApplicationController
  # GET /items
  def index
    respond_to do |format|
      format.html { raise "Oops"}
      format.json { render :json => Item.all }
    end
  end

  # POST /items
  def create
    @item = Item.create({
      :title => params[:title],
      :details => params[:details]
    })
                          
    respond_to do |format|
      format.html { raise "Oops"}
      format.json { render :json => @item }
    end
  end

  # POST /items/:id
  def update
    @item = Item.find(params[:id])
    
    @item.update({
      :title => params[:title],
      :details => params[:details]
    })
                          
    respond_to do |format|
      format.html { raise "Oops"}
      format.json { render :json => @item }
    end
  end

  # DELETE /items/:id
  def destroy
    Item.find(params[:id]).destroy
    
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
      raise "Unknown suggestion type during suggest..."
    end

    respond_to do |format|
      format.html { raise "Oops"}
      format.json {
        render :json => { :suggestions => suggestions }
      }
    end
  end

  # GET /info
  def info
    info = [ ]
    case params[:type]
    when "location"
      info = GooglePlace.info(params[:key])
    when "bookmark"
      info = Bookmark.info(params[:key])
    else
      raise "Unknown suggestion type during info..."
    end

    respond_to do |format|
      format.html { raise "Oops"}
      format.json {
        render :json => { :info => info }
      }
    end
  end

end
