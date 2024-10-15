# frozen_string_literal: true

require 'rails_helper'
require './app/policies/application_policy'
require './app/policies/organization_policy'

describe OrganizationPolicy, type: :policy do
  context 'when user is in the "owners" group' do
    organization = Fabricate(:organization)
    team = organization.teams.create(name: 'owners')
    user = Fabricate(:user)
    team.users << user
    team.save!

    expected_values = {
      'can-destroy': true,
      'can-access-via-teams': true,
      'can-create-module': true,
      'can-create-team': true,
      'can-create-workspace': true,
      'can-manage-users': true,
      'can-manage-subscription': true,
      'can-manage-sso': true,
      'can-update-oauth': true,
      'can-update-ssh-keys': true,
      'can-update-api-token': true,
      'can-traverse': true,
      'can-start-trial': true,
      'can-update-agent-pools': true,
      'can-manage-tags': true,
      'can-manage-varsets': true,
      'can-read-varsets': true,
      'can-manage-public-providers': true,
      'can-create-provider': true,
      'can-manage-public-modules': true,
      'can-manage-custom-providers': true,
      'can-manage-run-tasks': true,
      'can-read-run-tasks': true,
      'can-create-project': true,
      'can-manage-memberships': true
    }
    expected_values.each do |val, expected|
      it "has permission #{val} set to #{expected}" do
        policy = described_class.new(organization, user:)
        rule = "#{val.to_s.gsub('-', '_')}?"
        expect(policy.apply(rule.to_sym)).to be expected
      end
    end
  end

  context 'when user is not in the "owners" group' do
    organization = Fabricate(:organization)
    team = organization.teams.create(name: 'non-owners')
    user = Fabricate(:user)
    team.users << user
    team.save!
    OrganizationMembership.create(organization_id: organization.id, user_id: user.id)

    expected_values = {
      'can-destroy': false,
      'can-access-via-teams': false,
      'can-create-module': false,
      'can-create-team': false,
      'can-create-workspace': true,
      'can-manage-users': false,
      'can-manage-subscription': false,
      'can-manage-sso': false,
      'can-update-oauth': false,
      'can-update-ssh-keys': false,
      'can-update-api-token': false,
      'can-traverse': true,
      'can-start-trial': false,
      'can-update-agent-pools': false,
      'can-manage-tags': false,
      'can-manage-varsets': false,
      'can-read-varsets': false,
      'can-manage-public-providers': false,
      'can-create-provider': false,
      'can-manage-public-modules': false,
      'can-manage-custom-providers': false,
      'can-manage-run-tasks': false,
      'can-read-run-tasks': false,
      'can-create-project': false,
      'can-manage-memberships': false
    }
    expected_values.each do |val, expected|
      it "has permission #{val} set to #{expected}" do
        policy = described_class.new(organization, user:)
        rule = "#{val.to_s.gsub('-', '_')}?"
        expect(policy.apply(rule.to_sym)).to be expected
      end
    end
  end

  context 'when using an organization token' do
    organization = Fabricate(:organization)
    expected_values = {
      'can-destroy': true,
      'can-access-via-teams': true,
      'can-create-module': true,
      'can-create-team': true,
      'can-create-workspace': true,
      'can-manage-users': true,
      'can-manage-subscription': true,
      'can-manage-sso': true,
      'can-update-oauth': true,
      'can-update-ssh-keys': true,
      'can-update-api-token': true,
      'can-traverse': true,
      'can-start-trial': true,
      'can-update-agent-pools': true,
      'can-manage-tags': true,
      'can-manage-varsets': true,
      'can-read-varsets': true,
      'can-manage-public-providers': true,
      'can-create-provider': true,
      'can-manage-public-modules': true,
      'can-manage-custom-providers': true,
      'can-manage-run-tasks': true,
      'can-read-run-tasks': true,
      'can-create-project': true,
      'can-manage-memberships': true
    }
    expected_values.each do |val, expected|
      it "has permission #{val} set to #{expected}" do
        policy = described_class.new(organization, organization:)
        rule = "#{val.to_s.gsub('-', '_')}?"
        expect(policy.apply(rule.to_sym)).to be expected
      end
    end
  end
end
