Rails.application.config.action_mailer.delivery_method = :smtp
Rails.application.config.action_mailer.perform_deliveries = true
Rails.application.config.action_mailer.raise_delivery_errors = true
Rails.application.config.action_mailer.smtp_settings = {
  address: 'smtp.exmail.qq.com',
  port: 25,
  domain: 'tuodanbao.com',
  user_name: 'no-reply@tuodanbao.com',
  password: 'tuodanbao2014',
  authentication: 'plain',
  enable_starttls_auto: true
}#Settings.poster

Rails.application.config.action_mailer.default_url_options = {host: 'localhost', port: 3000} if Rails.env.development?
Rails.application.config.action_mailer.default_url_options = {host: 'www.tuodanbao.com'} if Rails.env.production?
