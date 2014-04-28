# Using JWT from Ruby is straight forward. The below example expects you to have `jwt`
# in your Gemfile, you can read more about that gem at https://github.com/progrium/ruby-jwt.
# Assuming that you've set your shared secret and Zendesk subdomain in the environment, you
# can use Zendesk SSO from your controller like this example.
require 'securerandom' unless defined?(SecureRandom)

class ZendeskSessionController < ApplicationController
  # configuration
  SECRET = Dashboard::Application.config.zendesk_secret
  SUBDOMAIN = Dashboard::Application.config.zendesk_subdomain


  def index
    if current_user && configured?
      sign_into_zendesk(current_user)
    else
      # don't sign in, just return
      if params['return_to'].present?
        redirect_to params['return_to']
      else
        redirect_to 'https://#{SUBDOMAIN}.zendesk.com/'
      end
    end
  end

  private

  def configured?
    SECRET.present? && SUBDOMAIN.present?
  end

  def sign_into_zendesk(user)
    # This is the meat of the business, set up the parameters you wish
    # to forward to Zendesk. All parameters are documented in this page.
    iat = Time.now.to_i
    jti = "#{iat}/#{SecureRandom.hex(18)}"

    payload = JWT.encode({
      :iat   => iat, # Seconds since epoch, determine when this token is stale
      :jti   => jti, # Unique token id, helps prevent replay attacks
      :name  => user.name,
      :email => user.email,
    }, SECRET)

    redirect_to zendesk_sso_url(payload)
  end

  def zendesk_sso_url(payload)
    url = "https://#{SUBDOMAIN}.zendesk.com/access/jwt?jwt=#{payload}"
    url += "&return_to=#{URI.escape(params["return_to"])}" if params["return_to"].present?
    url
  end
end
