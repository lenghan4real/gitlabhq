require 'spec_helper'

describe 'Profile > Personal Access Tokens', feature: true, js: true do
  let(:user) { create(:user) }

  before do
    login_as(user)
  end

  describe "token creation" do
    it "allows creation of a token with an optional expiry date" do
      visit profile_personal_access_tokens_path
      fill_in "Name", with: FFaker::Product.brand
      expect {click_on "Add Personal Access Token"}.to change { PersonalAccessToken.count }.by(1)

      active_personal_access_tokens = find(".table.active-personal-access-tokens").native['innerHTML']
      expect(active_personal_access_tokens).to match(PersonalAccessToken.last.name)
      expect(active_personal_access_tokens).to match("Never")
      expect(active_personal_access_tokens).to match(PersonalAccessToken.last.token)

      fill_in "Name", with: FFaker::Product.brand

      # Set date to 1st of next month
      find("a[title='Next']").click
      click_on "1"

      expect {click_on "Add Personal Access Token"}.to change { PersonalAccessToken.count }.by(1)

      active_personal_access_tokens = find(".table.active-personal-access-tokens").native['innerHTML']
      expect(active_personal_access_tokens).to match(PersonalAccessToken.last.name)
      expect(active_personal_access_tokens).to match(Date.today.next_month.at_beginning_of_month.to_s)
      expect(active_personal_access_tokens).to match(PersonalAccessToken.last.token)
    end
  end

  describe "inactive tokens" do
    it "allows revocation of an active token" do
      personal_access_token = create(:personal_access_token, user: user)
      visit profile_personal_access_tokens_path
      click_on "Revoke"

      inactive_personal_access_tokens = find(".table.inactive-personal-access-tokens").native['innerHTML']
      expect(inactive_personal_access_tokens).to match(personal_access_token.name)
      expect(inactive_personal_access_tokens).to match(personal_access_token.token)
    end

    it "moves expired tokens to the 'inactive' section" do
      personal_access_token = create(:personal_access_token, expires_at: 5.days.ago, user: user)
      visit profile_personal_access_tokens_path

      inactive_personal_access_tokens = find(".table.inactive-personal-access-tokens").native['innerHTML']
      expect(inactive_personal_access_tokens).to match(personal_access_token.name)
      expect(inactive_personal_access_tokens).to match(personal_access_token.token)
    end
  end
end
