class PlansController < ApplicationController
  before_filter :authenticate_user!

  # GET /plans
  def index
    respond_to do |format|
      format.html { raise "Oops" }
      format.json { render :json => Plan.all }
    end
  end

  # GET /plans
  def show
    @plan = Plan.find(params[:id])

    respond_to do |format|
      format.html { raise "Oops" }
      format.json { render :json => @plan }
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
      format.html { raise "Oops" }
      format.json { render :json => @plan }
    end
  end

  # POST /plans/:id
  def update
    @plan = Plan.find(params[:id])

    data = {
      :name => params[:name],
      :note => params[:note]
    }

    if @plan.destination_reference != params[:destination_reference]
      data.merge!({
                   :destination_reference => params[:destination_reference],
                   :destination => Destination.create(params[:destination_reference]).to_json
                 })
    end

    @plan.update(data)

    respond_to do |format|
      format.html { raise "Oops"}
      format.json { render :json => @plan }
    end
  end

  # DELETE /plans/:id
  def destroy
    Plan.find(params[:id]).destroy

    respond_to do |format|
      format.html { raise "Oops"}
      format.json { head :no_content }
    end
  end

end
