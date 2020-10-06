#:nodoc:
class Members::HomeController < ApplicationController
  skip_before_action :authenticate_admin!
  skip_before_action :authenticate_user!, only: [:confirm_add_funds]

  layout 'members'

  def index
    @member = Member.find(current_user.credentials_id)

    # information of the middlebar
    @balance = CheckoutBalance.find_by_member_id(current_user.credentials_id)
    @debt = Participant
            .where(paid: false, member: @member, reservist: false)
            .joins(:activity)
            .where('activities.start_date < NOW()')
            .sum(:price) \
     + Participant # The plus makes it work for all activities where the member does NOT have a modified price.
            .where(paid: false, price: nil, member: @member, reservist: false)
            .joins(:activity)
            .where('activities.start_date < NOW()')
            .sum('activities.price ')

    @pinned = Post.published.pinned
    @pagination, @unpinned = pagy(Post.published.unpinned)

    @years = (@member.join_date.study_year..Date.today.study_year).map { |year| ["#{ year }-#{ year + 1 }", year] }.reverse
    @participants =
      @member.activities
             .study_year(params['year'])
             .distinct
             .joins(:participants)
             .where(:participants => { member: @member, reservist: false })
             .order('start_date DESC')

    @transactions = CheckoutTransaction.where(:checkout_balance => CheckoutBalance.find_by_member_id(current_user.credentials_id)).order(created_at: :desc).limit(10)
    @transaction_costs = Settings.mongoose_ideal_costs
  end

  def edit
    @member = Member.includes(:educations).includes(:tags).find(current_user.credentials_id)
    @user = User.find_by_email(current_user.email)
    @applications = [] # TODO: Doorkeeper::Application.authorized_for(current_user)

    @member.educations.build(:id => '-1') if @member.educations.empty?
  end

  def revoke
    Doorkeeper::AccessToken.revoke_all_for params[:id], current_user
    redirect_to :users_edit
  end

  def update
    @user = User.find_by_email(current_user.email)
    @user.update(user_post_params)

    @member = Member.find(current_user.credentials_id)

    if @member.update member_post_params.except 'mailchimp_interests'
      MailchimpJob.perform_later @member.email, @member, (member_post_params[:mailchimp_interests].select { |_, val| val == '1' }) unless
        ENV['MAILCHIMP_DATACENTER'].blank? || member_post_params[:mailchimp_interests].nil?

      impressionist(@member, I18n.t('activerecord.attributes.impression.member.update'))

      cookies["locale"] = @user.language

      # the translation location was used here but that conflicted with the way
      # the translation was shown, as it was tried to translate it again there
      flash[:warning] = I18n.t('members.home.edit.email_confirmation') if @member.email != params[:member][:email]
      redirect_to users_edit_path, :notice => I18n.t('members.home.edit.profile_saved')
      return
    end

    @applications = [] # TODO: Doorkeeper::Application.authorized_for(current_user)

    render 'edit'
    return
  end

  def add_funds
    member = Member.find(current_user.credentials_id)
    balance = CheckoutBalance.find_or_create_by!(member: member)

    if ideal_transaction_params[:amount].to_f <= Settings.mongoose_ideal_costs
      flash[:notice] = I18n.t('failed', scope: 'activerecord.errors.models.ideal_transaction')
      redirect_to members_home_path
      return
    end

    if balance.nil?
      flash[:notice] = I18n.t('failed', scope: 'activerecord.errors.models.ideal_transaction')
      redirect_to members_home_path
      return
    end

    ideal = IdealTransaction.new(
      :description => I18n.t('activerecord.errors.models.ideal_transaction.attributes.checkout'),
      :amount => (ideal_transaction_params[:amount].to_f + Settings.mongoose_ideal_costs),
      :issuer => ideal_transaction_params[:bank],
      :member => member,

      :transaction_id => nil,
      :transaction_type => 'CheckoutTransaction',

      :redirect_uri => users_root_url
    )

    if ideal.save
      redirect_to ideal.mollie_uri
    else
      flash[:notice] = I18n.t('failed', scope: 'activerecord.errors.models.ideal_transaction')
      redirect_to members_home_path
    end
  end

  def download
    @member = Member.includes(:activities, :groups, :educations).find(current_user.credentials_id)
    @transactions = CheckoutTransaction.where(:checkout_balance => CheckoutBalance.find_by_member_id(current_user.credentials_id)).order(created_at: :desc)

    send_data render_to_string(:layout => false),
              :filename => "#{ @member.name.downcase.tr(' ', '-') }.html",
              :type => 'application/html',
              :disposition => 'attachment'
  end

  private

  def member_post_params
    params.require(:member).permit(:address,
                                   :house_number,
                                   :postal_code,
                                   :city,
                                   :phone_number,
                                   :emergency_phone_number,
                                   :email,
                                   :mailchimp_interests => {},
                                   educations_attributes: [:id, :status])
  end

  def user_post_params
    params.require(:member).permit(:language)
  end

  def ideal_transaction_params
    params.require(:ideal_transaction).permit(:bank, :amount)
  end
end
