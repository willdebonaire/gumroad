# frozen_string_literal: true

class DashboardPolicy < ApplicationPolicy
  def index?
    user.role_accountant_for?(seller) ||
    user.role_admin_for?(seller) ||
    user.role_marketing_for?(seller) ||
    user.role_support_for?(seller)
  end

  def download_tax_form? = index?
  def dismiss_getting_started_checklist? = index?
end
