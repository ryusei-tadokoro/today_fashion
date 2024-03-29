# frozen_string_literal: true

# 共通の機能やフィルターをここに定義します。
class ApplicationController < ActionController::Base
  include ApplicationHelper
  before_action :configure_permitted_parameters, if: :devise_controller?

  def configure_permitted_parameters
    # 新規登録時(sign_up時)にnameというキーのパラメーターを追加で許可する
    devise_parameter_sanitizer.permit(:sign_up,
                                      keys: %i[name prefecture_id second_prefecture_id constitution_id image])
    devise_parameter_sanitizer.permit(:account_update,
                                      keys: %i[name prefecture_id second_prefecture_id constitution_id image])
  end
end
