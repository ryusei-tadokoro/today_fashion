class WeatherController < ApplicationController
  before_action :validate_city, only: [:show]
  before_action :load_prefecture_data, only: [:index]
  before_action :authenticate_user!
  after_action :verify_authorized, except: [:index, :show]
  after_action :verify_policy_scoped, only: :index

  def index
    skip_policy_scope
    user_prefecture_id = current_user&.prefecture_id
    user_second_prefecture_id = current_user&.second_prefecture_id

    default_city = user_prefecture_id.present? ? Prefecture.find(user_prefecture_id).name : 'Tokyo'
    second_city = user_second_prefecture_id.present? ? Prefecture.find(user_second_prefecture_id).name : 'Osaka'

    @weather_data = fetch_weather_data(default_city)
    @second_weather_data = fetch_weather_data(second_city)

    flash.now[:alert] = '天気情報の取得に失敗しました。' unless @weather_data || @second_weather_data
  end

  def show
    user_prefecture_id = current_user&.prefecture_id
    user_second_prefecture_id = current_user&.second_prefecture_id
  
    default_city = user_prefecture_id.present? ? Prefecture.find(user_prefecture_id).name : 'Tokyo'
    second_city = user_second_prefecture_id.present? ? Prefecture.find(user_second_prefecture_id).name : 'Osaka'
  
    @weather_data = fetch_weather_data(params[:city] || default_city)
    @second_weather_data = fetch_weather_data(second_city)
  
    if @weather_data
      rainfall = @weather_data.dig('rain', '1h') || @weather_data.dig('rain', '3h') || 0
      @weather = extract_weather_data(@weather_data, rainfall)
      fetch_and_update_weather_forecast(params[:city] || default_city)
  
      send_line_notification("【#{@weather[:name]}】に降水が予測されています。傘をお持ちください。") if rainfall.positive?
    else
      redirect_to action: :index, alert: '天気情報の取得に失敗しました。'
    end
  end

  def map
    authorize :weather, :map?
    prefecture_ids = [1, 4, 13, 23, 15, 26, 34, 39, 40, 46, 47]
    prefectures = Prefecture.where(id: prefecture_ids)
  
    @weather_data = prefectures.map do |prefecture|
      { name: prefecture.name, weather: fetch_weather_data(prefecture.name) }
    end
  
    flash.now[:alert] = '天気情報の取得に失敗しました。' if @weather_data.any? { |data| data[:weather].nil? }
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

  def fetch_temperature(location)
    # 各都道府県の気温データを取得するロジックをここに記述
    # 例: WeatherService.get_temperature(location)
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

  def send_line_notification(message)
    # LINE通知を送信するコードをここに追加します
  end
end
