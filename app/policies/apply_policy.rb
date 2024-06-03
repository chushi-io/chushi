class ApplyPolicy < ApplicationPolicy
  def show?
    (user.present? && user.organizations.map{|org| org.id}.include?(record.organization_id))
  end
end