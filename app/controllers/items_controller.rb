class ItemsController < ApplicationController
  before_filter :authenticate_user!
  # GET /items
  def index
    respond_to do |format|
      format.html { raise "Oops"}
      format.json { render :json => Item.where({:plan_id => params[:plan_id]}) }
    end
  end

  # POST /items
  def create
    @plan = Plan.find(params[:plan_id])

    prepare_tags
    prepare_item_elements

    @item = Item.create({
                          :plan => @plan,
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
    @plan = Plan.find(params[:plan_id])

    prepare_tags
    prepare_item_elements

    @item = Item.find(params[:id])
    @item.update({
                   :plan => @plan,
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
    suggestionClass = get_class(params[:type])
    if suggestionClass == GooglePlace && params[:location_bias]
      suggestions = suggestionClass.suggest(params[:term], {:location => params[:location_bias], :radius => 10000})
    else
      suggestions = suggestionClass.suggest(params[:term])
    end

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
    infoClass = get_class(params[:type])
    information = infoClass.info(params[:key])
    information = [ information ] unless information.is_a? Array
    
    respond_to do |format|
      format.html { raise "Oops"}
      format.json {
        render :json => { :info => information }
      }
    end
  end

  def get_class(element_type)
    case element_type
    when "tag"
      Tag
    when "google_place"
      GooglePlace
    when "destination"
      Destination
    when "bookmark"
      Bookmark
    when "yelp"
      Yelp
    else
      raise "Unknown suggestion type during suggest..."
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
          @item_elements << ItemElement.create_element(element)
        end
      end
    end
  end

end
