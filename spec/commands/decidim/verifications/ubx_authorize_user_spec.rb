# frozen_string_literal: true

require "spec_helper"

module Decidim::Verifications::Omniauth
  describe UbxActionAuthorizer do
    subject { described_class.new(authorization, options, component, resource) }

    let(:organization) { create(:organization) }
    let(:user) { create(:user, :confirmed, organization: organization) }
    let(:authorization) { create(:authorization, user: user, metadata: { "status" => status }) }
    let(:component) { create(:component, organization: organization) }
    let(:resource) { nil }
    let(:options) { {} }
    let(:status) { "student" }

    context "when the status is 'student'" do
      it "returns authorized" do
        expect(subject.authorize).to eq([:ok, {}])
      end
    end

    context "when the status is not 'student'" do
      let(:status) { "teacher" }

      it "returns unauthorized with the status" do
        allow_any_instance_of(Decidim::Verifications::DefaultActionAuthorizer).to receive(:authorize).and_return([:ok, {}])
        expect(subject.authorize).to eq([:unauthorized, { fields: { "status" => "teacher" } }])
      end
    end

    context "when the status is empty" do
      let(:status) { nil }

      it "returns unauthorized with the status" do
        allow_any_instance_of(Decidim::Verifications::DefaultActionAuthorizer).to receive(:authorize).and_return([:ok, {}])
        expect(subject.authorize).to eq([:unauthorized, { fields: { "status" => nil } }])
      end
    end

    context "when the superclass returns a non-ok status code" do
      before do
        allow_any_instance_of(Decidim::Verifications::DefaultActionAuthorizer).to receive(:authorize).and_return([:forbidden, {}])
      end

      it "returns the status code and data from the superclass" do
        expect(subject.authorize).to eq([:forbidden, {}])
      end
    end
  end
end
