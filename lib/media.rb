class Magpie::Media < Magpie::Base
  attr_accessor :kind, :path, :url

  def self.load_medias_from_model(model)
    model.uploads.collect {|upload|
      Magpie::Media.new ({
        kind: upload.kind,
        path: upload.path,
        url: upload.source_url || upload.url
      })
    }
  end
end