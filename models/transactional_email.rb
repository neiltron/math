require 'mongoid'
require 'pony'

class TransactionalEmail
  def self.send_confirmation (user)
    subject = 'Signup confirmation'
    body = "You recently signed up for Math. <br><br><a href='http://" + ENV['MATH_DOMAIN'] + "/confirm?key=" + user.confirm_token + "'>Click here to confirm your account</a>."

    self.send_email(user, subject, body)
  end

  def self.send_forgot_pass_email (user)
    subject = 'Forgot password'
    body = "Someone used the forgot password form at Math. <br><br><a href='http://" + ENV['MATH_DOMAIN'] + "/resetpw?key=" + user.confirm_token + "'>Click here to change your password</a>."

    self.send_email(user, subject, body)
  end

  def self.send_email (user, subject, body)
    Pony.mail :to => user.email.to_s,
              :from => 'no-reply@' + ENV['MATH_DOMAIN'],
              :subject => subject,
              :body => body,
              :headers => { 'Content-Type' => 'text/html' },
              :via => :smtp,
              :via_options => PONY_CONFIG
  end
end