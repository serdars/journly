class ItemsController < ApplicationController
  # GET /plans/:plan_id/items
  def show
    respond_to do |format|
      format.html { raise "Oops"}
      format.json {
        render :json => [ "Dinner in Grouchy Chef", "Boeing Factory Tour", "Sushi @ West Seattle" ]
      }
    end
  end
end
