secret_key = Rails.application.secrets.stripe.try(:[], "secret_key")

if secret_key.present?
  Stripe.api_key = secret_key
  unless defined? STRIPE_JS_HOST
    STRIPE_JS_HOST = "https://js.stripe.com"
  end
else
  raise <<-MESSAGE

  ***************************************************
  Stripe API Keys are missing from config/secrets.yml
  ***************************************************

  You need to add:
  stripe:
    publishable_key: pk_test_.....
    secret_key: sk_test_.....

  to config/secrets.yml

  See config/secrets.yml.example

  MESSAGE
end
