class ReportsController < ApplicationController
  before_action :set_report, only: %i[ show approve ]
  before_action :set_user
  before_action :authorize

  # GET users/:user_id/reports/submitted
  def submitted
    validate_ownership(@user) do # user is the owner of these reports
      @reports = Report.where(submitter_id: @user.id) # list only reports where user is submitter

      render json: @reports
    end
  end

  # GET users/:user_id/reports/review
  def review
    validate_ownership(@user) do # user is the owner of these reports
      @reports = Report.where(approver_id: @user.id) # list only reports where user is approver

      render json: @reports
    end
  end

  # GET users/:user_id/reports/1/approve
  def approve
    validate_roles [ADMIN] do # if user is admin
      if @report.is_approver?(@user) # if user is the approver for this report
        if Date.current.on_weekday? # can only approve on weekdays
          @report.status = "approved"
          @report.save
          render json: @report
        else
          render json: {message: "Can only approve on weekedays"}, status: 401
        end
      end
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
