# frozen_string_literal: true

module Decidim
  module Verifications
    module Omniauth
      class OmniauthAuthorizationForm < AuthorizationHandler
        attribute :provider, String
        attribute :oauth_data, Hash
        validate :has_identity?

        def metadata
          super.merge!(provider: provider).merge!(oauth_data)
        end

        def unique_id
          identity_for_user&.uid
        end

        def form_attributes
          super - [:provider, :oauth_data]
        end

        def to_partial_path
          "#{handler_name.sub!(/_form$/, "")}/form"
        end

        private

        def manifest
          @manifest ||= Decidim::Verifications.find_workflow_manifest(provider)
        end

        def has_identity?
          identity_for_user&.present?
        end

        def organization
          current_organization || user.organization
        end

        def identity_for_user
          @identity_for_user ||= Decidim::Identity.find_by(organization: organization, user: user, provider: provider)
        end

        def identities_for_user
          @identities_for_user ||= Decidim::Identity.where(organization: organization, user: user)
        end

        def _clean_hash(data)
          data.transform_values { |v| v.is_a?(Hash) ? _clean_hash(v) : v }.compact
        end
      end
    end
  end
end
