require 'spec_helper'

describe User do

  let(:password) { 'ok-password' }
  let(:password_confirmation) { 'ok-password' }

  let(:user_properties) do
    { 
      name: "Example User", email: "user@example.com",
                          password: password, password_confirmation: password_confirmation
    }
  end
  
  let(:user) { User.new(user_properties) }
  subject { user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:authenticate) }

  it { should be_valid }

  describe "when name is not present" do
  	before { user.name = " " }
  	it { should_not be_valid }
  end

  describe "when email is not present" do
  	before { user.email = " " }
  	it { should_not be_valid }
  end

  describe "when name is too long" do
  	before { user.name = "a" * 51 }
  	it { should_not be_valid }
  end

  describe "when email format is invalid" do
  	it "should be invalid" do
  	  addresses = %w[user@foo,com user_a_foo.org example.user@foo. foo@bar_baz.com foo@bar+baz.com]
  	  addresses.each do |invalid_address|
  	  	user.email = invalid_address
  	  	expect(user).not_to be_valid
  	  end
  	end
  end

  describe "when email format is valid" do
  	it "should be valid" do
  	  addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
  	  addresses.each do |valid_address|
  	  	user.email = valid_address
  	  	expect(user).to be_valid
  	  end
  	end
  end

  describe "when email address is already taken" do
    before do
      user_with_same_email = user.dup
      user_with_same_email.email = user.email.upcase
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

  describe "when password is not present" do
    let(:user_properties) do
      { 
        name: "Example User", 
        email: "user@example.com"
      }
    end

    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before { user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "return value of authenticate" do
    before { user.save }
    let(:found_user) { User.find_by(email: user.email) }

    describe "with valid password" do
      it { should eq found_user.authenticate(user.password) }
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not eq user_for_invalid_password }
      specify { expect(user_for_invalid_password).to be_false }
    end
  end

  describe 'password' do
    it 'is invalid with a short password' do
      user = User.new(user_properties.merge(password: 'bad', password_confirmation: 'bad'))
      expect(user).to be_invalid
    end

    it 'is valid with a longer password' do
      user = User.new(user_properties.merge(password: 'nice and long', password_confirmation: 'nice and long'))
      expect(user).to be_valid
    end
  end
end