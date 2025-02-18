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

  if %(cas).include?(data[:provider])
    user = Decidim::User.find(data[:user_id])

    next unless user && data

    workflows = Decidim.authorization_workflows.select do |a|
      a.try(:omniauth_provider).to_s == data[:provider].to_s
    end

    next if workflows.empty?

    flash_for_granted = []
    flash_for_refused = []

    workflows.each do |workflow|
      ## -- KEYCLOAK TRIES -- ##
      # infos = data[:raw_data][:info]
      # status = data[:raw_data][:extra]["raw_info"]["status"]
      #
      # ## Merge the infos with the status
      # infos["status"] = status
      ## -- ##

      infos = data[:info]

      form = Decidim::Verifications::Omniauth::OmniauthAuthorizationForm.from_params(
        user: user, provider: workflow.omniauth_provider, oauth_data: infos
      )

      authorization = Decidim::Authorization.find_or_initialize_by(
        user: user, name: workflow.name
      )

      session = { "decidim.user_id" => user.id, "decidim.authorization_id" => authorization.id }

      Decidim::Verifications::Omniauth::ConfirmOmniauthAuthorization.call(authorization, form, session) do
        on(:ok) { flash_for_granted << I18n.t("authorizations.new.success", scope: "decidim.verifications.omniauth", locale: user.locale) }
        on(:invalid) { flash_for_refused << form.errors.to_h.values.join(". ") }
      end
    end
  end
end
