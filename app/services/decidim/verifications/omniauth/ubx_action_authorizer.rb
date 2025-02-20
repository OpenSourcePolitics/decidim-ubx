# frozen_string_literal: true

module Decidim
  module Verifications
    module Omniauth
      class UbxActionAuthorizer < Decidim::Verifications::DefaultActionAuthorizer
        def authorize
          status_code, data = super

          return [:unauthorized, data] if authorization.blank? || authorization.metadata.blank?

          status = authorization.metadata["status"]

          return [status_code, data] if status_code != :ok || status == "student"

          [:unauthorized, data.merge(fields: { "status" => status })]
        end
      end
    end
  end
end
