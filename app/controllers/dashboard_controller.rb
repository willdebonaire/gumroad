# frozen_string_literal: true

class DashboardController < Sellers::BaseController
  before_action :check_payment_details, only: :index

  layout "inertia", only: :index

  def index
    authorize :dashboard
    session.delete(:social_connect_return)

    if current_seller.suspended_for_tos_violation?
      redirect_to products_url
    else
      LargeSeller.create_if_warranted(current_seller)
      props = CreatorHomePresenter.new(pundit_user).creator_home_props
      SocialConnectFunnel.record_offers!(
        user: current_seller,
        connections: props[:social_connections],
        surface: "getting_started",
        skip: impersonating?,
      )
      render inertia: "Dashboard/Index",
             props: { creator_home: props }
    end
  end

  def download_tax_form
    authorize :dashboard

    year = Time.current.year - 1
    tax_form_download_url = current_seller.tax_form_1099_download_url(year:)
    return redirect_to tax_form_download_url, allow_other_host: true if tax_form_download_url.present?

    flash[:alert] = "A 1099 form for #{year} was not filed for your account."
    redirect_to dashboard_path
  end

  def dismiss_getting_started_checklist
    authorize :dashboard

    current_seller.update!(has_dismissed_getting_started_checklist: true)

    head :ok
  end
end
