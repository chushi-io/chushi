after "development:organizations" do
  # Create the development user
  @user1 = User
    .create_with(
      password: "tofuisgreat",
      confirmed_at: Time.now,
    ).find_or_create_by(email: 'tofu@tofuisgreat.com')

  @user2 = User
    .create_with(
      password: "tofu2isgreat",
      confirmed_at: Time.now,
    ).find_or_create_by(email: 'tofu@tofu2isgreat.com')
  @user3 = User
    .create_with(
      password: "tofu3isgreat",
      confirmed_at: Time.now,
    ).find_or_create_by(email: 'tofu@tofu3isgreat.com')

  # Attach to the default Chushi organization
  @org = Organization.find_by(name: "chushi")
  @org.users << @user1
  @org.users << @user2
  @org.users << @user3
  @org.save!


end
