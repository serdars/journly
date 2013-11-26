class PlansController < ApplicationController
  # GET /plans
  def index
    respond_to do |format|
      # Only place where we are returning html
      format.html { render }
      format.json { render :json => Plan.all }
    end
  end

  # POST /plans
  def create
    @plan = Plan.create({
                          :name => params[:name],
                          :note => params[:note],
                          :destination_reference => params[:destination_reference],
                          :destination => Destination.create(params[:destination_reference]).to_json
                        })

    respond_to do |format|
      format.html { raise "Oops"}
      format.json { render :json => @plan }
    end
  end
end
