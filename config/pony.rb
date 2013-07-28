PONY_CONFIG = {
  :address              => ENV['SMTP_HOST'],
  :port                 => ENV['SMTP_PORT'],
  :enable_starttls_auto => true,
  :user_name            => ENV['SMTP_USER'],
  :password             => ENV['SMTP_PASS'],
  :authentication       => :plain,
  :domain               => ENV['SMTP_DOMAIN']
}