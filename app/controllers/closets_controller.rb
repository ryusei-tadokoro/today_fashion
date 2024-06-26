# frozen_string_literal: true

# 衣類に関する操作を管理するコントローラーです。
class ClosetsController < ApplicationController
  before_action :set_closet, only: %i[show edit update destroy]
  before_action :set_categories_and_subcategories, only: %i[new edit]
  before_action :authenticate_user!
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  # GET /closets or /closets.json
  def index
    if user_signed_in?
      @user = current_user
      @closets = policy_scope(@user.closets)
    else
      redirect_to new_user_session_path, alert: I18n.t('alerts.login_required')
    end
  end

  # GET /closets/1 or /closets/1.json
  def show
    authorize @closet
  end

  # GET /closets/new
  def new
    @closet = Closet.new
    authorize @closet
  end

  # GET /closets/1/edit
  def edit
    authorize @closet
  end

  # POST /closets or /closets.json
  def create
    @closet = current_user.closets.new(closet_params)
    authorize @closet
    respond_to do |format|
      unless save_and_respond(format)
        set_categories_and_subcategories
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @closet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /closets/1 or /closets/1.json
  def update
    authorize @closet
    update_params = closet_update_params
    if @closet.update(update_params)
      redirect_to closet_url(@closet), notice: t('.success')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /closets/1 or /closets/1.json
  def destroy
    authorize @closet
    @closet.destroy
    redirect_to closets_url, notice: t('.success')
  end

  def subcategories_for_category
    category_id = params[:category_id]
    subcategories = Subcategory.where(category_id:)
    render json: subcategories
  end

  private

  def save_and_respond(format)
    if @closet.save
      format.html { redirect_to closet_url(@closet), notice: t('.success') }
      format.json { render :show, status: :created, location: @closet }
      true
    else
      false
    end
  end

  def set_closet
    @closet = Closet.find(params[:id])
  end

  def closet_params
    params.require(:closet).permit(:name, :category_id, :subcategory_id, :purchase_date, :size, :color,
                                   :purchase_location, :price, :usage_frequency, :season, :other_comments, :image)
  end

  def closet_update_params
    params.require(:closet).permit(
      :name, :category_id, :subcategory_id, :purchase_date, :size, :color,
      :purchase_location, :price, :usage_frequency, :season, :other_comments
    ).merge(image: params[:closet][:image].presence || @closet.image)
  end

  def set_categories_and_subcategories
    @categories = Category.all
    @subcategories = Subcategory.all
  end

  def result_handled?(result)
    if result[:error]
      flash.now[:alert] = result[:error]
      redirect_to new_closet_path
      return true
    end
    false
  end

  def image_param
    params[:closet][:image].presence || @closet.image
  end
end
