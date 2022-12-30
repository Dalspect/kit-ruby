class DepartmentsController < ApplicationController
  before_action :set_department, only: [:courses, :files, :klasses, :edit, :update, :destroy]

  before_action only: [:courses, :files] {authenticate_department_professor!(@department)}  
  before_action only: [:klasses, :edit, :update] {authenticate_department_professor!(@department)}
  before_action only: [:new, :create, :destroy] {authenticate_kit_admin!}

  # GET /departments
  def index
    @departments = Department.all
  end

  def courses
    @courses = @department.courses
  end
  
  def files
  end
  
  def klasses
    @klasses = @department.courses.map{|c| c.klass}.flatten
  end

  # GET /departments/new
  def new
    @department = Department.new
  end

  # GET /departments/1/edit
  def edit
  end

  # POST /departments
  def create
    @department = Department.new(department_params)
	
	r = Repo.create
    @department.repo = r

    respond_to do |format|
      if @department.save
	    r.init_files_repository
        format.html { redirect_to department_courses_path(@department), notice: 'Department was successfully created.' }
      else
	    r.destroy
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /departments/1
  def update
    respond_to do |format|
      if @department.update(department_params)
        format.html { redirect_to department_courses_path(@department), notice: 'Department was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /departments/1
  def destroy
    @department.destroy
    respond_to do |format|
      format.html { redirect_to departments_url, notice: 'Department was successfully deleted.' }
    end
  end

  private
    
    def set_department
      @department = Department.find(params[:id])
    end

    def department_params
      params.require(:department).permit(:title)
    end
end
