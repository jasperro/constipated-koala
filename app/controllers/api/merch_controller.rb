#:nodoc:
class Api::MerchController < ApiController
  # These are disabled for now. Will be re-enabled when we've written a proper guide on koala-panda integration.
  # before_action -> { doorkeeper_authorize! 'participant-read' }, only: :index
  # before_action -> { doorkeeper_authorize! 'participant-write' }, only: [:create, :update, :destroy]

  def index
    if params[:order_id].present?
      @order = Merch.where(order_id: params[:order_id])
    elsif params[:member_id].present?
      @order = Merch.where(:member => Authorization._member)
    else
      head :bad_request
      return
    end

    render status: :ok, json: @order
  end

  def create
    @member = Member.find_by_email("test@svsticky.nl"); # TODO: Change into actual member
    @order_id = params[:order_id];

    params[:items].each do |item|
      @merch = Merch.new(
        :member => @member, 
        :order_id => @order_id, 
        :item_entry_id => item[:item_entry_id],
        :item_size => item[:item_size],
        :item_color => item[:item_color],
        :quantity => item[:quantity],
        :status => "preOrder"                     # TODO: Status is null at the moment, how do we fix?
      )
      p @merch

      # For now I'm just saving regardless. There should be a better way to save an array of changes.      
      @merch.save
      
      # Not sure about this one either... 
      # It can crash in the middle of saving an entire order and only process half of it.
      # head(:bad_request) && return unless @merch.save 
    end

    render :status => :created
  end

  def update
    raise NotImplementedError
  end

  def destroy
    raise NotImplementedError
  end
end
