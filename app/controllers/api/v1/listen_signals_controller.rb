class Api::V1::ListenSignalsController < Api::V1::BaseController
  before_action :get_brand, only: [:index, :show, :create, :update, :destroy]
  before_action :get_listen_signal, only: [:show, :destroy, :update]
  before_action :ensure_user_can_get_signal_info, only: [:index, :show, :destroy]
  before_action :ensure_user_can_get_listen_signal, only: [:show, :destroy]
  before_action :has_valid_subscription?, only: [:update, :create]

  def index
    render json: @brand.listen_signals, each_serializer: ListenSignalSerializer
  end

  def show
    render json: @listen_signal, serializer: ListenSignalSerializer
  end

  def templates
    render json: listen_signal_template_types
  end

  def update
    request_method = request.env['REQUEST_METHOD']
    if request_method == 'PUT'
      put_update
    elsif request_method == 'PATCH'
      patch_update
    end
  end

  def create
    signal_params            = create_signal_params
    response_params          = create_response_params
    signal_params[:brand]    = @brand
    signal_params[:identity] = @brand.twitter_identity
    default_response_msg     = response_params[:default_response]
    repeat_response_msg      = response_params[:repeat_response]
    timed_responses          = response_params[:responses]

    ActiveRecord::Base.transaction do
      @listen_signal = ListenSignal.create!(signal_params)
      create_grouped_response(default_response_msg, repeat_response_msg, timed_responses)
    end

    render json: @listen_signal, serializer: ListenSignalSerializer
  end

  def destroy
    @listen_signal.destroy

    head :no_content
  end

  private

  def create_signal_params
    params.permit(:name, :active, :signal_type)
  end

  def create_response_params
    params.permit(:default_response, :repeat_response, { responses: [:id, :message, :expiration_date] })
  end

  def update_signal_params
    params.permit(:signal_type, :expiration_date)
  end

  def patch_signal_params
    params.permit(:active)
  end

  def get_listen_signal
    @listen_signal = ListenSignal.find(params[:id])
  end

  def ensure_user_can_get_signal_info
    if current_user.brand_id != @brand.id
      raise ApiErrors::StandardError.new(
        message: 'Sorry, you are not authorized to perfom this action',
        status: 401,
      )
    end
  end

  def ensure_user_can_get_listen_signal
    if !@brand.listen_signal_ids.include?(@listen_signal.id)
      raise ApiErrors::StandardError.new(
        message: 'Sorry, you are not authorized to perfom this action',
        status: 401,
      )
    end
  end

  def listen_signal_template_types
    {
      templates: {
        ListenSignal::Types::OFFER => 'Send a special offer every time a follower sends a custom hashtag',
        ListenSignal::Types::TODAY => 'Send a summary of your location or event each day a follower uses a custom hashtag',
        ListenSignal::Types::CONTEST => 'Run a contest for your followers for a specific date range',
        ListenSignal::Types::REMINDER => 'Send a reminder on a specific date to users when they use a custom hashtag',
        ListenSignal::Types::CUSTOM => 'Create your own custom response whenever a follower sends a custom hashtag'      }
    }
  end

  def patch_update
    @listen_signal.update!(patch_signal_params)
  end

  def put_update
    signal_params = update_signal_params
    response_params = create_response_params

    ActiveRecord::Base.transaction do
      @listen_signal.update_attributes!(signal_params)
      update_response(@listen_signal.default_response, response_params[:default_response])
      update_response(@listen_signal.repeat_response, response_params[:repeat_response])
      handle_timed_responses(response_params[:responses], @listen_signal.response_group)
    end
  end

  def create_grouped_response(default_response_msg, repeat_response_msg, timed_responses)
    response_group = create_response_group
    create_response(default_response_msg, Response::Type::DEFAULT, response_group)
    create_response(repeat_response_msg, Response::Type::REPEAT, response_group)

    timed_responses.map do|response|
      create_timed_response(response[:message], response[:expiration_date], response_group)
    end
  end

  def create_response_group
    ResponseGroup.create!(listen_signal: @listen_signal)
  end

  def create_response(message, type, response_group)
    Response.create_response(message, type, response_group)
  end

  def create_timed_response(message, expiration_date, response_group)
    Response.create_timed_response(message, Response::Type::TIMED, expiration_date, response_group)
  end

  def handle_timed_responses(responses, response_group)
    handle_responses_for_delete(responses, response_group)
    handle_responses_for_update(responses, response_group)
  end

  def handle_responses_for_delete(responses, response_group)
    all_timed_responses_ids = response_group.timed_responses.pluck(:id)
    updatable_response_ids = responses.collect{ |r| r[:id] }
    deletable_response_ids = all_timed_responses_ids - updatable_response_ids

    deletable_response_ids.map do |id|
      response = Response.find(id)
      response.destroy
    end
  end

  def handle_responses_for_update(responses, response_group)
    responses.map do |response|
      if response.key?(:id)
        response = Response.find(response[:id])
        response.update_attributes!({
          message: response[:message],
          expiration_date: response[:expiration_date]
        })
      else
        create_timed_response(response[:message], response[:expiration_date], response_group)
      end
    end
  end

  def update_response(response, message, exp_date=nil)
    response.update!(message: message, expiration_date: exp_date)
  end
end
