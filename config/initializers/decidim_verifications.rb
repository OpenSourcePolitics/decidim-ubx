# frozen_string_literal: true

require "decidim/verifications/omniauth/engine"
require "decidim/verifications/omniauth/admin_engine"

# Decidim::Verifications.register_workflow(:dummy_authorization_handler) do |workflow|
#   workflow.form = "DummyAuthorizationHandler"
#   workflow.action_authorizer = "DummyAuthorizationHandler::ActionAuthorizer"
#   workflow.expires_in = 1.hour
#
#   workflow.options do |options|
#     options.attribute :postal_code, type: :string, default: "08001", required: false
#   end
# end
#
# Decidim::Verifications.register_workflow(:another_dummy_authorization_handler) do |workflow|
#   workflow.form = "AnotherDummyAuthorizationHandler"
#   workflow.expires_in = 1.hour
#
#   workflow.options do |options|
#     options.attribute :passport_number, type: :string, required: false
#   end
# end

if Rails.env.test?
  Decidim::Verifications.register_workflow(:dummy_authorization_handler) do |workflow|
    workflow.form = "DummyAuthorizationHandler"
    workflow.action_authorizer = "DummyAuthorizationHandler::DummyActionAuthorizer"
    workflow.expires_in = 1.hour

    workflow.options do |options|
      options.attribute :postal_code, type: :string, default: "08001", required: false
    end
  end
else
  Decidim::Verifications.register_workflow(:osp_authorization_handler) do |auth|
    auth.form = "Decidim::OspAuthorizationHandler"
  end
end

Decidim::Verifications.register_workflow(:cas) do |workflow|
  workflow.engine = Decidim::Verifications::Omniauth::Engine
  workflow.admin_engine = Decidim::Verifications::Omniauth::AdminEngine
  workflow.omniauth_provider = :cas
end

Decidim::Verifications.register_workflow(:cas_student) do |workflow|
  workflow.engine = Decidim::Verifications::Omniauth::Engine
  workflow.admin_engine = Decidim::Verifications::Omniauth::AdminEngine
  workflow.action_authorizer = "Decidim::Verifications::Omniauth::UbxActionAuthorizer"
  workflow.omniauth_provider = :cas
end
