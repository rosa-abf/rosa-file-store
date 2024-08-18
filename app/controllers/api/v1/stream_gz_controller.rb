class Api::V1::StreamGzController < Api::ApplicationController
  include ActionController::Live

  def show
    file_store = FileStore.find_by!(sha1_hash: params[:id])

    redirect_to download_path(params[:id]) and return if file_store.file_name !~ /.*\.log.gz$/

    infile = gz = nil

    infile = open(file_store.file.path)
    gz = Zlib::GzipReader.new(infile)
    response.headers['Content-Type'] = 'text/plain'
    response.headers['Content-Disposition'] = 'inline'
    loop do
      chunk = gz.read(65535)
      response.stream.write chunk
      break if gz.eof?
    end
    ensure
      gz.close if gz
      infile.close if infile
      response.stream.close
  end
end
