# frozen_string_literal: true

module WorkflowManifestExtends
  extend ActiveSupport::Concern

  included do
    attribute :omniauth_provider, String
    attribute :minimum_age, Integer, default: 0
    attribute :anti_affinity, Array[String], default: []
  end
end

Decidim::Verifications::WorkflowManifest.class_eval do
  include(WorkflowManifestExtends)
end


