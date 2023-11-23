module UploadedFile
  def uploaded_file(name:)
    Rack::Test::UploadedFile.new(StringIO.new, original_filename: name)
  end
end
