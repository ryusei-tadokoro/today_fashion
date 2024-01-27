class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  def configure_permitted_parameters
    # 新規登録時(sign_up時)にnameというキーのパラメーターを追加で許可する
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :prefecture_id, :second_prefecture_id, :constitution_id, :image])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :prefecture_id, :second_prefecture_id, :constitution_id, :image])
  end

  private

  def kelvin_to_celsius(kelvin)
    (kelvin - 273.15).round(1)
  end
end
