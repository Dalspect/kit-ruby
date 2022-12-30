class GradeCategoriesController < ApplicationController
  
  # Note that currently grade categories can only belong to a course since courseless classes were removed.
  # This file and others still have code for class grade categories because we have discussed overriding
  #  the categories on a per-class level as a future feature, so it may be useful again later.
  
  before_action :set_grade_category, only: [:edit, :update, :destroy]
  
  before_action :authenticate_logged_in!
  
  before_action :authenticate_grade_category_admin!, only: [:edit, :update, :destroy]
  
  before_action :authenticate_grade_category_admin_create!, only: [:create]

  # GET /grade_categories/new
  def new
    @grade_category = GradeCategory.new
	if params[:course]
	  @grade_category.course_id = params[:course]
	elsif params[:class]
	  @grade_category.klass_id = params[:class]
	end
  end

  # GET /grade_categories/1/edit
  def edit
  end

  # POST /grade_categories
  # POST /grade_categories.json
  def create
    @grade_category = GradeCategory.new(grade_category_params)

    respond_to do |format|
      if @grade_category.save
        format.html { redirect_to get_class_or_course_categories_url(@grade_category), notice: 'Grade category was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /grade_categories/1
  # PATCH/PUT /grade_categories/1.json
  def update
    respond_to do |format|
      if @grade_category.update(grade_category_params)
        format.html { redirect_to get_class_or_course_categories_url(@grade_category), notice: 'Grade category was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /grade_categories/1
  # DELETE /grade_categories/1.json
  def destroy
    # Return user to course/class that owned this category
    c = @grade_category.destroy
	
    respond_to do |format|
      format.html { redirect_to get_class_or_course_categories_url(c), notice: 'Grade category was successfully destroyed.' }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_grade_category
      @grade_category = GradeCategory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def grade_category_params
      params.require(:grade_category).permit(:title, :klass_id, :course_id, :weight)
    end
	
	def authenticate_grade_category_admin!
	  if @grade_category.klass
	    authenticate_class_admin! @grade_category.klass
	  else
	    #Part of course
		authenticate_department_professor!(@grade_category.course.department)
	  end
	end
	
	def authenticate_grade_category_admin_create!
	  unless grade_category_params[:klass_id].empty?
	    authenticate_class_admin! Klass.find(grade_category_params[:klass_id])
	  else
	    #Part of course
	    authenticate_department_professor!(Course.find(grade_category_params[:course_id]).department)
	  end
	end
	
	def get_class_or_course_categories_url(c)
	  if c.course
	    course_grade_categories_path(c.course)
	  elsif c.klass
	    edit_klass_path(c.klass)
	  end
	end
end
