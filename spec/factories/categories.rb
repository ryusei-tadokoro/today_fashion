# frozen_string_literal: true

# spec/factories/categories.rb
FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "カテゴリ#{n}" }
  end
end
