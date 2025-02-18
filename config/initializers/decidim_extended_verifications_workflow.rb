# frozen_string_literal: true

module Decidim
  module Verifications
    class WorkflowManifest
      attribute :omniauth_provider, String
      attribute :minimum_age, Integer, default: 0
    end
  end
end
