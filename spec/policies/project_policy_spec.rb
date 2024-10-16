frozen_string_literal: true

# frozen_string_literal: true

require 'rails_helper'
require './app/policies/application_policy'
require './app/policies/project_policy'

describe ProjectPolicy, type: :policy do
  organization = Fabricate(:organization)
  team = organization.teams.create(name: 'owners')

  context 'when user is in the "owners" group' do
    project = Fabricate(:project, organization:)
    user = Fabricate(:user)
    team.users << user
    team.save!

    expected_values = {
      'can-update': true,
      'can-destroy': true,
      'can-create-workspace': true
    }

    expected_values.each do |val, expected|
      it "has permission #{val} set to #{expected}" do
        policy = described_class.new(project, user:)
        rule = "#{val.to_s.gsub('-', '_')}?"
        expect(policy.apply(rule.to_sym)).to be expected
      end
    end
  end

  project_access_levels = {
    read: {
      'can-update': false,
      'can-destroy': false,
      'can-create-workspace': false
    },
    write: {
      'can-update': false,
      'can-destroy': false,
      'can-create-workspace': false
    },
    maintain: {
      'can-update': false,
      'can-destroy': false,
      'can-create-workspace': false
    },
    admin: {
      'can-update': true,
      'can-destroy': true,
      'can-create-workspace': true
    }
  }

  project_access_levels.each do |access, permissions|
    context "when user is in a project-team with \"#{access}\" access" do
      project = Fabricate(:project, organization:)
      user = Fabricate(:user)
      project_team = Fabricate(:team, organization:)
      project_team.users << user
      project_team.save!
      TeamProject.create!(project:, team: project_team, organization:, access:)
      permissions.each do |val, expected|
        it "has permission #{val} set to #{expected}" do
          policy = described_class.new(project, user:)
          rule = "#{val.to_s.gsub('-', '_')}?"
          expect(policy.apply(rule.to_sym)).to be expected
        end
      end
    end
  end
end
