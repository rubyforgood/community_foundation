class Admin::AllocationCategoriesController < Admin::ApplicationController
  before_action :set_category, only: %i[ edit update destroy ]

  def index
    @categories = categories.order(:name).to_a
  end

  def new
    type = params[:type].presence_in(AllocationCategory::TAB_CLASSES) || AllocationCategory::TAB_CLASSES.first
    @category = categories.new(type: type)
  end

  def create
    @category = categories.new(category_params)
    if @category.save
      redirect_to admin_allocation_categories_path(type: @category.type), notice: "Category created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @category.update(category_params)
      redirect_to admin_allocation_categories_path(type: @category.type), notice: "Category updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @category.destroy
    redirect_to admin_allocation_categories_path(type: @category.type), notice: "Category deleted."
  end

  private

  def categories
    Current.organization.allocation_categories
  end

  def set_category
    @category = categories.find(params[:id])
  end

  def category_params
    params.require(:allocation_category).permit(:name, :type, :parent_id)
  end
end
