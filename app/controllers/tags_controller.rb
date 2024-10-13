# frozen_string_literal: true

class TagsController < AuthenticatedController
  # TODO: Tags are not unique per organization, but are instead
  # global to the installation. These need to be moved to a
  # multi tenant architecture
  def index; end

  def new; end

  def edit; end

  def create; end

  def update; end

  def destroy; end

  private

  def tag_params; end
end
