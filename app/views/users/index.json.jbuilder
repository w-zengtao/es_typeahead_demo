json.array!(@users) do |user|
  json.extract! user, :id, :name, :email, :token
  json.url user_url(user, format: :json)
end
