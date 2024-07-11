class ReportsController < ApplicationController
  before_action :set_report, only: %i[ show approve ]
  before_action :set_user
  before_action :authorize

  # GET users/:user_id/reports/submitted
  def submitted
    validate_ownership(@user) do
      @reports = Report.where(submitter_id: @user.id)

      render json: @reports
    end
  end

  # GET users/:user_id/reports/review
  def review
    @reports = Report.where(approver_id: @user.id)

    render json: @reports
  end

  # GET users/:user_id/reports/1/approve
  def approve
    validate_roles [ADMIN] do
      if @report.is_approver?(@user)
        @report.status = "approved"
        @report.save
      end

      render json: @report
    end
  end

  # GET users/:user_id/reports/1
  def show
    render json: @report
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_report
      @report = Report.find(params[:id])
    end

    def set_user
      @user = User.find(params[:user_id])
    end
end
