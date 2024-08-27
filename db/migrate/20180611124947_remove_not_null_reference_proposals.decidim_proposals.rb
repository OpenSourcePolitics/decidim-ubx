# frozen_string_literal: true

# This migration comes from decidim_proposals (originally 20170410073742)

class RemoveNotNullReferenceProposals < ActiveRecord::Migration[5.0]
  def change
    change_column_null :decidim_proposals_proposals, :reference, true
  end
end
