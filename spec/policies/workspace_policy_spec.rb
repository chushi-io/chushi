# frozen_string_literal: true

require 'rails_helper'
require './app/policies/application_policy'
require './app/policies/workspace_policy'

describe WorkspacePolicy, type: :policy do
  organization = Fabricate(:organization)
  team = organization.teams.create(name: 'owners')

  context 'when user is in the "owners" group' do
    workspace = Fabricate(:workspace, organization:)
    user = Fabricate(:user)
    team.users << user
    team.save!

    WorkspaceTeam.create(workspace:, team:)
    expected_values = {
      'can-update': true,
      'can-destroy': true,
      'can-queue-run': true,
      'can-read-run': true,
      'can-read-variable': true,
      'can-update-variable': true,
      'can-read-state-versions': true,
      'can-read-state-outputs': true,
      'can-create-state-versions': true,
      'can-queue-apply': true,
      'can-lock': true,
      'can-unlock': true,
      'can-force-unlock': true,
      'can-read-settings': true,
      'can-manage-tags': true,
      'can-manage-run-tasks': true,
      'can-force-delete': true,
      'can-manage-assessments': true,
      'can-manage-ephemeral-workspaces': true,
      'can-read-assessment-results': true,
      'can-queue-destroy': true
    }

    expected_values.each do |val, expected|
      it "has permission #{val} set to #{expected}" do
        policy = described_class.new(workspace, user:)
        rule = "#{val.to_s.gsub('-', '_')}?"
        expect(policy.apply(rule.to_sym)).to be expected
      end
    end
  end

  team_access_checks = {
    admin: {
      'can-update': true,
      'can-destroy': true,
      'can-queue-run': true,
      'can-read-run': true,
      'can-read-variable': true,
      'can-update-variable': true,
      'can-read-state-versions': true,
      'can-read-state-outputs': true,
      'can-create-state-versions': true,
      'can-queue-apply': true,
      'can-lock': true,
      'can-unlock': true,
      'can-force-unlock': true,
      'can-read-settings': true,
      'can-manage-tags': true,
      'can-manage-run-tasks': true,
      'can-force-delete': true,
      'can-manage-assessments': true,
      'can-manage-ephemeral-workspaces': true,
      'can-read-assessment-results': true,
      'can-queue-destroy': true
    },
    read: {
      'can-update': false,
      'can-destroy': false,
      'can-queue-run': false,
      'can-read-run': true,
      'can-read-variable': true,
      'can-update-variable': false,
      'can-read-state-versions': true,
      'can-read-state-outputs': true,
      'can-create-state-versions': false,
      'can-queue-apply': false,
      'can-lock': false,
      'can-unlock': false,
      'can-force-unlock': false,
      'can-read-settings': true,
      'can-manage-tags': false,
      'can-manage-run-tasks': false,
      'can-force-delete': false,
      'can-manage-assessments': false,
      'can-manage-ephemeral-workspaces': false,
      'can-read-assessment-results': true,
      'can-queue-destroy': false
    },
    plan: {
      'can-update': false,
      'can-destroy': false,
      'can-queue-run': true,
      'can-read-run': true,
      'can-read-variable': true,
      'can-update-variable': false,
      'can-read-state-versions': true,
      'can-read-state-outputs': true,
      'can-create-state-versions': false,
      'can-queue-apply': false,
      'can-lock': true,
      'can-unlock': true,
      'can-force-unlock': false,
      'can-read-settings': true,
      'can-manage-tags': false,
      'can-manage-run-tasks': false,
      'can-force-delete': false,
      'can-manage-assessments': false,
      'can-manage-ephemeral-workspaces': false,
      'can-read-assessment-results': true,
      'can-queue-destroy': false
    },
    write: {
      'can-update': false,
      'can-destroy': false,
      'can-queue-run': true,
      'can-read-run': true,
      'can-read-variable': true,
      'can-update-variable': true,
      'can-read-state-versions': true,
      'can-read-state-outputs': true,
      'can-create-state-versions': true,
      'can-queue-apply': true,
      'can-lock': true,
      'can-unlock': true,
      'can-force-unlock': true,
      'can-read-settings': true,
      'can-manage-tags': false,
      'can-manage-run-tasks': false,
      'can-force-delete': false,
      'can-manage-assessments': false,
      'can-manage-ephemeral-workspaces': true,
      'can-read-assessment-results': true,
      'can-queue-destroy': true
    }
  }

  team_access_checks.each do |access, permissions|
    context "when user is in a workspace-team with \"#{access}\" access" do
      workspace = Fabricate(:workspace, organization:)
      user = Fabricate(:user)
      workspace_team = Fabricate(:team, organization:)
      workspace_team.users << user
      workspace_team.save!
      WorkspaceTeam.create!(workspace:, organization:, team: workspace_team, access:)
      permissions.each do |val, expected|
        it "has permission #{val} set to #{expected}" do
          policy = described_class.new(workspace, user:)
          rule = "#{val.to_s.gsub('-', '_')}?"
          expect(policy.apply(rule.to_sym)).to be expected
        end
      end
    end
  end

  project_access_checks = {
    admin: {
      'can-update': true,
      'can-destroy': true,
      'can-queue-run': true,
      'can-read-run': true,
      'can-read-variable': true,
      'can-update-variable': true,
      'can-read-state-versions': true,
      'can-read-state-outputs': true,
      'can-create-state-versions': true,
      'can-queue-apply': true,
      'can-lock': true,
      'can-unlock': true,
      'can-force-unlock': true,
      'can-read-settings': true,
      'can-manage-tags': true,
      'can-manage-run-tasks': true,
      'can-force-delete': true,
      'can-manage-assessments': true,
      'can-manage-ephemeral-workspaces': true,
      'can-read-assessment-results': true,
      'can-queue-destroy': true
    },
    maintain: {
      'can-update': true,
      'can-destroy': true,
      'can-queue-run': true,
      'can-read-run': true,
      'can-read-variable': true,
      'can-update-variable': true,
      'can-read-state-versions': true,
      'can-read-state-outputs': true,
      'can-create-state-versions': true,
      'can-queue-apply': true,
      'can-lock': true,
      'can-unlock': true,
      'can-force-unlock': true,
      'can-read-settings': true,
      'can-manage-tags': true,
      'can-manage-run-tasks': true,
      'can-force-delete': true,
      'can-manage-assessments': true,
      'can-manage-ephemeral-workspaces': true,
      'can-read-assessment-results': true,
      'can-queue-destroy': true
    },
    write: {
      'can-update': false,
      'can-destroy': false,
      'can-queue-run': true,
      'can-read-run': true,
      'can-read-variable': true,
      'can-update-variable': false,
      'can-read-state-versions': true,
      'can-read-state-outputs': true,
      'can-create-state-versions': true,
      'can-queue-apply': true,
      'can-lock': true,
      'can-unlock': true,
      'can-force-unlock': false,
      'can-read-settings': true,
      'can-manage-tags': false,
      'can-manage-run-tasks': false,
      'can-force-delete': false,
      'can-manage-assessments': false,
      'can-manage-ephemeral-workspaces': false,
      'can-read-assessment-results': true,
      'can-queue-destroy': true
    },
    read: {
      'can-update': false,
      'can-destroy': false,
      'can-queue-run': true,
      'can-read-run': true,
      'can-read-variable': true,
      'can-update-variable': false,
      'can-read-state-versions': true,
      'can-read-state-outputs': true,
      'can-create-state-versions': false,
      'can-queue-apply': false,
      'can-lock': false,
      'can-unlock': false,
      'can-force-unlock': false,
      'can-read-settings': true,
      'can-manage-tags': false,
      'can-manage-run-tasks': false,
      'can-force-delete': false,
      'can-manage-assessments': false,
      'can-manage-ephemeral-workspaces': false,
      'can-read-assessment-results': true,
      'can-queue-destroy': false
    }
  }

  project_access_checks.each do |access, permissions|
    context "when user is in a workspace-project with \"#{access}\" access" do
      user = Fabricate(:user)
      project = Fabricate(:project, organization:)
      workspace = Fabricate(:workspace, organization:, project:)
      team = Fabricate(:team, organization:)
      TeamMembership.create!(team:, user:)
      TeamProject.create!(project:, team:, organization:, access:)
      # puts workspace.project.team_projects.inspect
      permissions.each do |val, expected|
        it "has permission #{val} set to #{expected}" do
          policy = described_class.new(workspace, user:)
          rule = "#{val.to_s.gsub('-', '_')}?"
          expect(policy.apply(rule.to_sym)).to be expected
        end
      end
    end
  end
end
