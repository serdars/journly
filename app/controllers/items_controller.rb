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
    prepare_tags
    prepare_item_elements
    
    @item = Item.create({
                          :title => params[:title],
                          :details => params[:details],
                          :tags => @tags,
                          :item_elements => @item_elements
                        })
                          
    respond_to do |format|
      format.html { raise "Oops"}
      format.json { render :json => @item }
    end
  end

  # POST /items/:id
  def update
    prepare_tags
    prepare_item_elements

    @item = Item.find(params[:id])
    @item.update({
                   :title => params[:title],
                   :details => params[:details],
                   :tags => @tags,
                   :item_elements => @item_elements
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

    suggestionClass = case params[:type]
                      when "tag"
                        Tag
                      when "location"
                        GooglePlace
                      else
                        raise "Unknown suggestion type during suggest..."
                      end
    
    suggestions = suggestionClass.suggest(params[:term])

    respond_to do |format|
      format.html { raise "Oops"}
      format.json {
        render :json => {
          :suggestion_type => params[:type],
          :suggestions => suggestions
        }
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

  def prepare_tags
    @tags = [ ]
    
    if params[:tags] && !params[:tags].empty?
      params[:tags].each do |tag|
        if tag[:id]
          @tags << Tag.find(tag[:id])
        else
          @tags << Tag.create(:name => tag[:name])
        end
      end
    end
  end

  def prepare_item_elements
    @item_elements = [ ]
    
    if params[:item_elements] && !params[:item_elements].empty?
      params[:item_elements].each do |element|
        if element[:id]
          @item_elements << ItemElement.find(element[:id])
        else
          raise "Not implemented yet..."
          @item_elements << ItemElement.create(:name => element[:name])
        end
      end
    end
  end

end
