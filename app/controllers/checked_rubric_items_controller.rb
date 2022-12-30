class CheckedRubricItemsController < ApplicationController
  before_action :set_checked_rubric_item, only: [:show, :edit, :update, :destroy]

  # GET /checked_rubric_items
  # GET /checked_rubric_items.json
  def index
    @checked_rubric_items = CheckedRubricItem.all
  end

  # GET /checked_rubric_items/1
  # GET /checked_rubric_items/1.json
  def show
  end

  # GET /checked_rubric_items/new
  def new
    @checked_rubric_item = CheckedRubricItem.new
  end

  # GET /checked_rubric_items/1/edit
  def edit
  end

  # POST /checked_rubric_items
  # POST /checked_rubric_items.json
  def create
    @checked_rubric_item = CheckedRubricItem.new(checked_rubric_item_params)

    respond_to do |format|
      if @checked_rubric_item.save
        format.html { redirect_to @checked_rubric_item, notice: 'Checked rubric item was successfully created.' }
        format.json { render :show, status: :created, location: @checked_rubric_item }
      else
        format.html { render :new }
        format.json { render json: @checked_rubric_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /checked_rubric_items/1
  # PATCH/PUT /checked_rubric_items/1.json
  def update
    respond_to do |format|
      if @checked_rubric_item.update(checked_rubric_item_params)
        format.html { redirect_to @checked_rubric_item, notice: 'Checked rubric item was successfully updated.' }
        format.json { render :show, status: :ok, location: @checked_rubric_item }
      else
        format.html { render :edit }
        format.json { render json: @checked_rubric_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /checked_rubric_items/1
  # DELETE /checked_rubric_items/1.json
  def destroy
    @checked_rubric_item.destroy
    respond_to do |format|
      format.html { redirect_to checked_rubric_items_url, notice: 'Checked rubric item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_checked_rubric_item
      @checked_rubric_item = CheckedRubricItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def checked_rubric_item_params
      params.require(:checked_rubric_item).permit(:rubric_item_id, :graded_problem_id)
    end
end
