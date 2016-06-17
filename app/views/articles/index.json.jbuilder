json.array!(@articles) do |article|
  json.extract! article, :id, :title, :author_id, :content, :remark
  json.url article_url(article, format: :json)
end
