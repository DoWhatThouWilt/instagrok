alias Instagrok.Posts.Post
alias Instagrok.Posts
alias Instagrok.Accounts
alias Faker.Lorem

[user_id | _] = System.argv()
user = Accounts.get_user!(String.to_integer(user_id))

for n <- 1..15 do
  Posts.create_post(
    %Post{},
    %{
      description: Lorem.paragraph(4),
      photo_url: "https://picsum.photos/id/#{:rand.uniform(1084)}/400/500"
    },
    user
  )
end

