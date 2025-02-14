# frozen_string_literal: true

require "omniauth/strategies/ubx"

Rails.application.config.middleware.use OmniAuth::Builder do
  OmniAuth.config.logger = Rails.logger

  omniauth_config = Rails.application.secrets.fetch(:omniauth, {}).with_indifferent_access

  if omniauth_config[:cas].present?
    provider(
      OmniAuth::Strategies::UBX,
      setup: lambda { |env|
        request = Rack::Request.new(env)
        organization = env["decidim.current_organization"].presence || Decidim::Organization.find_by(host: request.host)
        provider_config = organization.enabled_omniauth_providers[:cas] || {}

        env["omniauth.strategy"].options[:host] = provider_config[:host] || omniauth_config.dig(:cas, :host)
        env["omniauth.strategy"].options[:ssl] = provider_config[:ssl] || omniauth_config.dig(:cas, :ssl)
      }
    )
  end
end

ActiveSupport::Notifications.subscribe "decidim.user.omniauth_registration" do |_name, data|
  Rails.logger.debug "decidim.user.omniauth_registration event in config/initializers/omniauth_cas.rb"
  # Rails.logger.debug data

  if %(openid_connect).include?(data[:provider]) # TODO : change to cas
    user = Decidim::User.find(data[:user_id])

    # TODO : see code @ https://github.com/OpenSourcePolitics/decidim/tree/alt/petition/decidim-verifications/lib/decidim/verifications/omniauth#L127

  end
end