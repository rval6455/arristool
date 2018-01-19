json.array!(@cmts) do |cmt|
  json.extract! cmt, :host, :name, :downstream_freq
  json.url cmt_url(cmt, format: :json)
end
