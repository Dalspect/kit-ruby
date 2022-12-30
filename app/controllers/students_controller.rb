class StudentsController < ApplicationController
  before_action :set_student, only: [:destroy, :toggle_assigned_notification, :toggle_contributor_notification, :toggle_graded_notification, :toggle_extension_notification, :toggle_regrade_response_notification]
  before_action :set_student_preload, only: [:show]
  before_action :set_klass, only: [:index]
  
  before_action :authenticate_logged_in!
  before_action only: [:index] {authenticate_class_admin!(@klass)}
  before_action only: [:create] {authenticate_class_admin!(Klass.find(student_params[:klass_id]))}
  before_action only: [:show] {authenticate_class_admin!(@student.klass)}
 
  before_action :authenticate_self!, only: [:toggle_assigned_notification, :toggle_contributor_notification, :toggle_graded_notification, :toggle_extension_notification, :toggle_regrade_response_notification] 
  
  def index
  end
  
  def show
  end
  
  # POST /students
  # POST /students.json
  def create
    #Counters for success message
	already_in = []
	#already_invited = []
	new_invite = []
	failed = []
	
	
	student_params[:emails].gsub(/[\s]/,'').split(',').each do |email|
	
	  #Check if email is already in the system
	  u = User.find_by email: email
	  if u
	    # User already exists
		@student = Student.new
	    @student.klass_id = student_params[:klass_id]
	    @student.user = u
        if @student.save
          already_in.push(email)
        else
          failed.push(email)
        end
	  else
	    # User does not exist!
	    # Has this user been invited before?
		#invite = UserInvite.find_by email: email
		#if invite
		  #Try to add class to this invite
		#  klass_invite = UserKlassInvite.new
		#  klass_invite.user_invite = invite
		#  klass_invite.klass_id = student_params[:klass_id]
		# 
		#  if klass_invite.save
		#    already_invited.push(email)
		#  else
		#    failed.push(email)
		#  end
		#else
		  #Invite this user
		  invite = User.new
		  invite.email = email
		  invite.set_default_password
		  
		  if invite.save
		    student = Student.new
			student.klass_id = student_params[:klass_id]
			student.user = invite
		    
			if student.save
			  new_invite.push(email)
			else
			  failed.push(email)
			end
		  else
		    failed.push(email)
		  end
		#end
	  end
	end
	
	redirect_to klass_students_path(student_params[:klass_id]), notice: 
	  already_in.size.to_s + " existing users added: "+already_in.join(", ")+"; "+new_invite.size.to_s+" new invitations sent: "+new_invite.join(", "),
	  alert: "Failed to add " + failed.size.to_s + " users: "+failed.join(", ")
  end

  # DELETE /students/1
  # DELETE /students/1.json
  def destroy
    s = @student.destroy
    respond_to do |format|
      format.html { redirect_to klass_students_path(@student.klass), notice: 'Student was successfully removed.' }
      format.json { head :no_content }
    end
  end
  
  
  def toggle_assigned_notification
    @student.toggle!(:notify_assignment_assigned)
	if @student.notify_assignment_assigned
	  redirect_to notification_settings_path, notice: "Notifications enabled!"
	else
	  redirect_to notification_settings_path, notice: "Notifications disabled!"
	end
  end
  
  def toggle_graded_notification
    @student.toggle!(:notify_graded)
	if @student.notify_graded
	  redirect_to notification_settings_path, notice: "Notifications enabled!"
	else
	  redirect_to notification_settings_path, notice: "Notifications disabled!"
	end
  end
  
  def toggle_contributor_notification
    @student.toggle!(:notify_contributor_invite)
	if @student.notify_contributor_invite
	  redirect_to notification_settings_path, notice: "Notifications enabled!"
	else
	  redirect_to notification_settings_path, notice: "Notifications disabled!"
	end
  end
  
  def toggle_extension_notification
    @student.toggle!(:notify_extension)
	if @student.notify_extension
	  redirect_to notification_settings_path, notice: "Notifications enabled!"
	else
	  redirect_to notification_settings_path, notice: "Notifications disabled!"
	end
  end

  def toggle_regrade_response_notification
    @student.toggle!(:notify_regrade_response)
	if @student.notify_regrade_response
	  redirect_to notification_settings_path, notice: "Notifications enabled!"
	else
	  redirect_to notification_settings_path, notice: "Notifications disabled!"
	end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_student
      @student = Student.find(params[:id])
    end
	
	def set_student_preload
	  @student = Student.where(id: params[:id]).includes([
	    klass:[
		  course:[
		    :grade_category
		  ],
		  assigned: [
		     submissions:[
			  graded_problems: [:checked_rubric_items],
			  contributors: [
				user: [
				  :extensions
				]
			  ],
			  past_contributors:[
				user: [
				  :extensions
				]
			  ],
			  regrade_requests: [],
			],
			assignment:[
			  problems: [:rubric_items],
			  grade_category: []
			]
		  ]
		],
		
		user:[
		  extensions:[],
		  contributors:[
		    submission: [
			  graded_problems: [:checked_rubric_items],
			  contributors: []
			]
		  ],
		  past_contributors:[
		    submission: [
			  graded_problems: [:checked_rubric_items],
			  contributors: []
			]
		  ],
		]	  
	  ]).first
	end
	
	def set_klass
	  @klass = Klass.where(id: params[:klass_id]).includes([
		students: [
		  user:[
		    contributors:[
			  submission: [
			    :regrade_requests
			  ]
			],
			extensions: []
		  ]
		],
		course:[
		  :grade_category
		]
	  
	  ]).first
	  
	  @assigneds = @klass.assigned.order(:due_date).includes([
	    submissions:[
		  graded_problems: [:checked_rubric_items],
		  contributors: [
			user: [
			  :extensions
			]
		  ],
		  past_contributors:[
			user: [
			  :extensions
		    ]
		  ],
		  regrade_requests: []
	    ],
	    assignment:[
		  problems: [:rubric_items],
		  grade_category: []
	    ]
	    
	  ])
	end

    # Never trust parameters from the scary internet, only allow the white list through.
    def student_params
      params.permit(:emails, :klass_id)
    end
	
	def authenticate_self!
	  if @student.user != current_user
	    redirect_to root_url, notice: "That action can only be performed on yourself!"
	  end
	end
end
