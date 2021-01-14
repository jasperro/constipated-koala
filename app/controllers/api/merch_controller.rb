#:nodoc:
class Api::MerchController < ApiController
  before_action -> { doorkeeper_authorize! 'participant-read' }, only: :index
  before_action -> { doorkeeper_authorize! 'participant-write' }, only: [:create, :update, :destroy]

  def index
    if params[:order_id].present?
      @order = Merch.find_by_order_id(params[:order_id])
    elsif params[:member_id].present?
      @order = Merch.where(:member => Authorization._member)
    else
      head :bad_request
      return
    end

    render status: :ok, json: @order
  end

  def create
    @merch = Merch.new(
      :member => Authorization._member, 
      :order_id => params[:order_id], 
      :item_id => params[:item_id],
      :price => params[:price],
      :status => 1
    )

    head(:bad_request) && return unless @merch.save

    render :status => :created
  end

  def update
    raise NotImplementedError
  end

  def destroy
    raise NotImplementedError
  end
end