after "development:organizations" do
  # Create the development user
  @user = User
    .create_with(
      password: "tofuisgreat",
      confirmed_at: Time.now,
    ).find_or_create_by(email: 'tofu@tofuisgreat.com')

  # Attach to the default Chushi organization
  @org = Organization.find_by(name: "chushi")
  @org.users << @user
  @org.save!
end
