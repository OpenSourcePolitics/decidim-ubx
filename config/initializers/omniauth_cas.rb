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
