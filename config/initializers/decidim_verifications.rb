# frozen_string_literal: true

require "extends/decidim/verifications/workflow_manifest_extends"
require "decidim/verifications/omniauth"

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

Decidim::Verifications.unregister_workflow(:csv_census)
Decidim::Verifications.unregister_workflow(:id_documents)
Decidim::Verifications.unregister_workflow(:postal_letter)
Decidim::Verifications.unregister_workflow(:sms)

Decidim::Verifications.register_workflow(:cas) do |workflow|
  workflow.engine = Decidim::Verifications::Omniauth::Engine
  workflow.admin_engine = Decidim::Verifications::Omniauth::AdminEngine
  workflow.omniauth_provider = :openid_connect  # TODO : change to :cas
end

Decidim::Verifications.register_workflow(:cas_student) do |workflow|
  workflow.engine = Decidim::Verifications::Omniauth::Engine
  workflow.admin_engine = Decidim::Verifications::Omniauth::AdminEngine
  workflow.action_authorizer = "Decidim::Verifications::Omniauth::UbxActionAuthorizer"
  workflow.omniauth_provider = :openid_connect  # TODO : change to :cas
end