require 'net/http'

class Api::V1::FileStoresController < Api::ApplicationController
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  before_action :authenticate, only: %i(create destroy check)

  # GET /file_stores?hash=3a93e5553490e39b4cd50269d51ad8438b7e20b8
  # GET /file_stores.json?hash=3a93e5553490e39b4cd50269d51ad8438b7e20b8
  def index
    fs = FileStore.by_hash(params[:hash])

    file_stores = fs.map do |item|
      item.touch
      {
        sha1_hash: item.sha1_hash,
        file_name: File.basename(item.file.path),
        user: {
          id: item.user_id,
          uname: item.user_uname
        }
      }
    end
    render json: file_stores
  end

  def show
    file_store = FileStore.find_by!(sha1_hash: params[:id])

    if file_store.file_name =~/.*\.log.gz$/
      redirect_to stream_gz_path(id: params[:id])
    elsif file_store.file_name =~ /.*\.(log|txt|md5sum)$/
      send_file file_store.file.path, x_sendfile: false, type: 'text/plain', disposition: 'inline'
    else
      send_file file_store.file.path, x_sendfile: false
    end
  end

  # POST /file_stores
  # POST /file_stores.json
  def create
    file       = params[:file_store][:file]
    file_store = FileStore.new
    file_store.sha1_hash = Digest::SHA1.file(file.path).hexdigest
    file_store.file      = file
    file_store.user_id, file_store.user_uname = user['id'], user['uname']

    if file_store.save
      File.delete file.path
      render json: { sha1_hash: file_store.sha1_hash }, status: :created
    else
      render json: file_store.errors, status: :unprocessable_entity
    end
  end

  # DELETE /file_stores/1
  # DELETE /file_stores/1.json
  def destroy
    file_store = FileStore.find_by_sha1_hash!(params[:id])
    if user['id'] == file_store.user_id || user['role'] == 'admin' ||
        (user['uname'] == 'file_store' && user['role'] == 'system')
      file_store.destroy
      head :no_content
    else
      render_error 403
    end
  end

  def check
    render json: true, status: 200
  end

  private

  def user
    @user ||= JSON.parse(@res.body)['user']
  end

  def authenticate
    authenticate_or_request_with_http_basic do |user, pass|
      @res =
        Rails.cache.fetch(['Api::V1::FileStoresController#authenticate', user, pass], expires_in: 15.minutes) do
          uri  = URI.parse("https://abf.rosalinux.ru/api/v1/user.json")
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          req = Net::HTTP::Get.new(uri.request_uri, {'Content-Type' =>'application/json'})
          req.basic_auth user, pass
          http.request(req)
        end

      unless @res.code == '200'
        message = {} # Plupload expect array at values
        JSON.parse(@res.body).each { |k, v| message["#{k.capitalize}:"] = [v] }
        render json: message, status: @res.code.to_i
      end
      @res.code == '200'
    end
  end
end
