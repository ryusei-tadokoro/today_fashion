# frozen_string_literal: true

require 'httparty'
require 'uri'

class WeatherController < ApplicationController
  before_action :validate_city, only: [:show]
  before_action :load_prefecture_data, only: [:index]

  def index
    user_prefecture_id = current_user&.prefecture_id
    user_second_prefecture_id = current_user&.second_prefecture_id

    # デフォルトの都市とセカンドの都市を取得
    default_city = user_prefecture_id.present? ? Prefecture.find(user_prefecture_id).name : 'Tokyo'
    second_city = user_second_prefecture_id.present? ? Prefecture.find(user_second_prefecture_id).name : 'Osaka'

    # デフォルトの都市の天気データを取得
    @weather_data = fetch_weather_data(default_city)

    # セカンドの都市の天気データを取得
    @second_weather_data = fetch_weather_data(second_city)

    # デフォルトの都市とセカンドの都市のどちらか一方でもデータが存在すれば成功とみなす
    flash.now[:alert] = '天気情報の取得に失敗しました。' unless @weather_data || @second_weather_data
  end

  def show
    @weather_data = fetch_weather_data(params[:city])
    if @weather_data
      rainfall = @weather_data.dig('rain', '1h') || @weather_data.dig('rain', '3h') || 0
      @weather = extract_weather_data(@weather_data, rainfall)
      fetch_and_update_weather_forecast(params[:city])

      # 降水量がある場合はLINE通知を送信
      send_line_notification("【#{@weather[:name]}】に降水が予測されています。傘をお持ちください。") if rainfall.positive?
    else
      redirect_to action: :index, alert: '天気情報の取得に失敗しました。'
    end
  end

  private

  def validate_city
    redirect_to(action: :index, alert: '都市名を入力してください。') if params[:city].blank?
  end

  def load_prefecture_data
    csv_path = Rails.root.join('prefectures.csv')
    @prefecture_data = CSV.read(csv_path, headers: true).map { |row| [row['prefecture'], row['english']] }
  end

  def fetch_weather_data(city)
    response = WeatherService.new(city).fetch_weather
    response.success? ? response.parsed_response : nil
  end

  def extract_weather_data(weather_data, rainfall)
    {
      name: weather_data['name'],
      temp_celsius: kelvin_to_celsius(weather_data['main']['temp']).round(1),
      feels_like_celsius: kelvin_to_celsius(weather_data['main']['feels_like']).round(1),
      temp_min_celsius: kelvin_to_celsius(weather_data['main']['temp_min']).round(1),
      temp_max_celsius: kelvin_to_celsius(weather_data['main']['temp_max']).round(1),
      humidity: weather_data['main']['humidity'],
      wind_speed: weather_data['wind']['speed'],
      description: weather_data['weather'][0]['description'],
      rainfall:
    }
  end

  def fetch_and_update_weather_forecast(city)
    response_forecast = WeatherService.new(city).fetch_weather_forecast
    @weather_data = response_forecast.parsed_response if response_forecast.success?
  end

  def kelvin_to_celsius(kelvin)
    kelvin - 273.15
  end
end
