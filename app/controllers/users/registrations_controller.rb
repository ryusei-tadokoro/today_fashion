# frozen_string_literal: true

# Users::RegistrationsController manages user registration and profile updates.
module Users
  class RegistrationsController < Devise::RegistrationsController
    before_action :set_prefectures, only: %i[new create edit update]
    before_action :set_constitutions, only: %i[new create edit update]
    skip_before_action :verify_authenticity_token, only: [:create]

    def new
      @user = initialize_user
      @step = params[:step] || 'step1'
      render "users/registrations/#{@step}"
    end

    def edit
      @user = current_user
    end

    def create
      session[:user_params].deep_merge!(user_params) if user_params
      @user = User.new(session[:user_params])
      @step = params[:step] || 'step1'

      if @user.valid?(step_validation_context(@step))
        handle_valid_step
      else
        render "users/registrations/#{@step}"
      end
    end

    def update
      @user = current_user

      if update_resource(@user, user_params)
        bypass_sign_in(@user)
        redirect_to root_path, notice: I18n.t('devise.registrations.account_updated')
      else
        render :edit
      end
    end

    def cancel_account
      @user = current_user
    end

    def destroy
      @user = current_user
      if @user.destroy
        redirect_to root_path, notice: I18n.t('devise.registrations.account_deleted')
      else
        redirect_to cancel_account_user_path, alert: I18n.t('devise.registrations.account_deletion_failed')
      end
    end

    protected

    def update_resource(resource, params)
      if params[:password].blank? && params[:password_confirmation].blank?
        resource.update_without_password(params)
      else
        resource.update(params)
      end
    end

    private

    def initialize_user
      session[:user_params] ||= {}
      user = User.new
      user.attributes = session[:user_params]
      user
    end

    def handle_valid_step
      if @step == 'step2'
        @user.save
        sign_in(@user)
        redirect_to root_path, notice: I18n.t('devise.registrations.account_created')
      else
        redirect_to new_user_registration_step_path(step: next_step(@step))
      end
    end

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :prefecture_id,
                                   :second_prefecture_id, :constitution_id, :image)
    end

    def set_prefectures
      @prefectures = Prefecture.all
    end

    def set_constitutions
      @constitutions = Constitution.all
    end

    def step_validation_context(step)
      case step
      when 'step1' then :step1
      when 'step2' then :step2
      end
    end

    def next_step(current_step)
      'step2' if current_step == 'step1'
    end
  end
end
