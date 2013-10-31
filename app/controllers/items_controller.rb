class ItemsController < ApplicationController
  # GET /plans/:plan_id/items
  def show
    respond_to do |format|
      format.html { raise "Oops"}
      format.json {
        render :json => [ "Minikom", "Eux C", "Datca" ]
      }
    end
  end
end
