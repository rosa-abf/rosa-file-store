class Api::ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token

  rescue_from Exception, with: :render_500
  rescue_from ActiveRecord::RecordNotFound,
              ActionController::RoutingError,
              AbstractController::ActionNotFound, with: :render_404

  protected

  def render_404
    render_error 404
  end

  def render_500(e)
    Raven.capture_exception(e)
    render_error 500
  end

  def render_error(status)
    render json: { "Error #{status}" => [I18n.t("#{status}_message")] }, status: status
  end
end
