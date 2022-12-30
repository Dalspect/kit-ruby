# Preview all emails at http://localhost:3000/rails/mailers/accounts_mailer
class AccountsMailerPreview < ActionMailer::Preview
  def password_reset_email
    AccountsMailer.password_reset_email(User.first, "TEST_TOKEN")
  end

  def invite_user_email
    AccountsMailer.invite_user_email(UserInvite.first, "TEST_TOKEN")
  end
end
