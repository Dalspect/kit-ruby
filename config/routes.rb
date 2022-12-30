Rails.application.routes.draw do
 
  resources :departments, only: [:index, :new, :create, :edit, :update, :destroy] do
    resources :department_professors, only: [:create, :update, :destroy]
  end
  get 'departments/:id/courses', to: 'departments#courses', as: 'department_courses'
  get 'departments/:id/files', to: 'departments#files', as: 'department_files'
  get 'departments/:id/klasses', to: 'departments#klasses', as: 'department_classes'

  resources :extensions, only: [:new, :create, :edit, :update, :destroy]

  resources :ssh_keys, only: [:new, :create, :index, :destroy]

  resources :contributor_invites, only: [:destroy, :create] do
    post 'accept', to: 'contributor_invites#accept', as: 'accept'
  end
  resources :contributors, only: [:create, :destroy]
  resources :submissions, only: [:new, :create, :show, :index, :destroy] do
    resources :graded_problems, only: [:create, :edit, :update, :index]
    post 'turn_in', to: 'submissions#turn_in', as: 'turn_in'

    get 'grade', to: 'submissions#grade', as: 'grade'
    patch 'adjustments', to: 'submissions#adjustments', as: 'adjustments'
    post 'force_turn_in', to: 'submissions#force_turn_in', as: 'force_turn_in'
    post 'un_turn_in', to: 'submissions#un_turn_in', as: 'un_turn_in'

    get 'download', to: 'submissions#download', as: 'download'
    #get 'render_file', to: 'submissions#render_file', as: 'render_file'
    get 'download_inline', to: 'submissions#download_inline', as: 'download_inline'
    patch 'add_file', to: 'submissions#add_file', as: 'add_file'
    patch 'add_url', to: 'submissions#add_url', as: 'add_url'

    post 'reset_notification', to: 'submissions#reset_notification', as: 'reset_notification'
    
    post 'regrade_request', to: 'regrade_requests#create', as: 'create_regrade_request'
    patch 'regrade_requests/:id/close', to: 'regrade_requests#close', as: 'close_regrade_request'

  end

  get 'submission/new_professor', to: 'submissions#new_professor', as: 'submission_professor_new_upload'
  post 'submission/new_professor', to: 'submissions#create_professor', as: 'submission_professor_upload'
  post 'submission/new_blank', to: 'submissions#create_blank', as: 'submission_create_blank'

  resources :assignments, only: [:show, :edit, :update, :new, :create, :destroy] do

    resources :problems, only: [:index, :new, :create, :edit, :update, :destroy] do
      post 'move_up', to: 'problems#move_up', as: 'move_up'
      post 'move_down', to: 'problems#move_down', as: 'move_down'
      resources :rubric_items, only: [:create, :update, :destroy] do
        post 'move_up', to: 'rubric_items#move_up', as: 'move_up'
        post 'move_down', to: 'rubric_items#move_down', as: 'move_down'
      end
      resources :reusable_comments, only: [:create, :destroy]
    end
    
    # Assigning, unassigning, assign settings
    get 'assign', to: 'assigneds#new', as: 'assign'
    post 'assign', to: 'assigneds#create'
    get 'assigned/:id', to: 'assigneds#edit', as: 'assigned'
    patch 'assigned/:id', to: 'assigneds#update'
    get 'assigned/:id/grade_settings', to: 'assigneds#grade_settings', as: 'grade_settings'
    get 'unassign/:id', to: 'assigneds#destroy', as: 'unassign'
    patch 'assigned/:id/adjustments', to: 'assigneds#adjustments', as: 'adjustments'
    patch 'assigned/:id/toggle_hide_grades', to: 'assigneds#toggle_hide_grades', as: 'assigned_toggle_hide_grades'
    post 'assigned/:id/reset_notifications', to: 'assigneds#reset_notifications', as: 'assigned_reset_notifications'

    # Bulk file operations
    get 'assigned/:id/bulk_download', to: 'assigneds#bulk_download', as: 'bulk_download'
    get 'assigned/:id/bulk_upload', to: 'assigneds#view_bulk_upload', as: 'view_bulk_upload'
    post 'assigned/:id/bulk_upload', to: 'assigneds#bulk_upload', as: 'bulk_upload'

    get 'assigned/:id/bulk_sort', to: 'assigneds#view_bulk_sort', as: 'view_bulk_sort'
    post 'assigned/:id/bulk_sort', to: 'assigneds#bulk_sort', as: 'bulk_sort'
    get 'assigned/:id/bulk_uploads/download', to: 'assigneds#download_bulk_file', as: 'bulk_uploaded_download'
    get 'assigned/:id/bulk_uploads/view_file', to: 'assigneds#view_bulk_file', as: 'bulk_uploaded_view_file'

    # Assignment 'gradebook'
    get 'assigned/:id/gradebook', to: 'assigneds#gradebook', as: 'assigned_gradebook'
    get 'assigned/:id/gradebook_csv', to: 'assigneds#gradebook_csv', as: 'assigned_gradebook_csv'

    # Grade by problem
    get 'assigned/:id/problems', to: 'assigneds#problems', as: 'assigned_problems'
    get 'assigned/:id/problem/:problem_id', to: 'assigneds#show_problem', as: 'show_grade_problem'
    patch 'assigned/:id/problem/:problem_id', to: 'assigneds#grade_problem', as: 'grade_problem'
  
    # Rubric copying
    get 'copy_rubric', to: 'assignments#view_copy_rubric', as: 'view_copy_rubric'
    post 'copy_rubric', to: 'assignments#copy_rubric', as: 'copy_rubric'

    # Clone all script
    get 'assigned/:id/clone_all', to: 'assigneds#clone_all', as: 'clone_all'
  end
  
  get 'copy_assignment', to: 'assignments#show_copy_assignment', as: 'show_copy_assignment'

  post 'add_grader', to: 'assigned_graders#create', as: 'add_grader'
  delete 'assigned_grader/:id', to: 'assigned_graders#destroy', as: 'remove_grader'

  resources :grade_categories, only: [:new, :create, :edit, :update, :destroy]
  resources :graders, only: [:create, :destroy]
  resources :students, only: [:create, :destroy, :show]
  resources :professors, only: [:create, :destroy]

  resources :users, only: [:index, :update, :destroy]
  get 'users/:id/edit_admin', to: 'users#edit_admin', as: 'user_edit_admin'
  get 'users/edit_self', to: 'users#edit_self', as: 'user_edit_self'
  get 'change_password', to: 'users#change_password', as: 'change_password'
  post 'change_password', to: 'users#update_password', as: 'update_password'
  
  post 'users/create', to: 'users#create', as: 'create_user_invite'
  get 'users/:id/set_up', to: 'users#show_invite', as: 'show_user_invite'
  post 'users/:id/accept_invite', to: 'users#accept_invite', as: 'accept_user_invite'
  post 'users/:id/resend_invite', to: 'users#resend_invite', as: 'resend_user_invite'

  get 'request_password_reset', to: 'password_reset#show_password_reset_request', as: 'show_request_password_reset'
  post 'request_password_reset', to: 'password_reset#request_password_reset', as: 'request_password_reset'
  get 'use_password_reset', to: 'password_reset#show_use_password_reset', as: 'show_use_password_reset'
  post 'use_password_reset', to: 'password_reset#use_password_reset', as: 'use_password_reset'

  # Notifications
  get 'users/notification_settings', to: 'users#notification_settings', as: 'notification_settings'

  post 'students/:id/toggle_assigned_notification', to: 'students#toggle_assigned_notification', as: 'toggle_assigned_notification'
  post 'students/:id/toggle_graded_notification', to: 'students#toggle_graded_notification', as: 'toggle_graded_notification'
  post 'students/:id/toggle_contributor_notification', to: 'students#toggle_contributor_notification', as: 'toggle_contributor_notification'
  post 'students/:id/toggle_extension_notification', to: 'students#toggle_extension_notification', as: 'toggle_extension_notification'  
  post 'students/:id/toggle_regrade_response_notification', to: 'students#toggle_regrade_response_notification', as: 'toggle_regrade_response_notification'

  post 'graders/:id/toggle_assigned_notification', to: 'graders#toggle_assigned_notification', as: 'toggle_grader_assigned_notification'
  post 'assigneds/:id/toggle_submission_notification', to: 'assigneds#toggle_submission_notification', as: 'toggle_submitted_to_grader_notification'
  post 'assigneds/:id/toggle_regrade_request_notification', to: 'assigneds#toggle_regrade_request_notification', as: 'toggle_regrade_request_notification'

  resources :klasses do
    get 'gradebook', to: 'klasses#gradebook', as: 'gradebook'
    get 'gradebook_csv', to: 'klasses#gradebook_csv', as: 'gradebook_csv'

    get 'assignments', to: 'assignments#index', as: 'assignments'
    get 'files', to: 'klasses#files', as: 'files'
    get 'students', to: 'students#index', as: 'students'
    get 'graders', to: 'graders#index', as: 'graders'
  end
  
  #Courses
  resources :courses, only: [:show, :edit, :update, :new, :create, :destroy]
  get 'courses/:id/files', to: 'courses#files', as: 'course_files'
  get 'courses/:id/grade_categories', to: 'courses#grade_categories', as: 'course_grade_categories'  

  get 'repos/:id/download', to: 'repos#download', as: 'download'
  get 'repos/:id/view_file', to: 'repos#view_file', as: 'view_file'
  post 'repos/:id/upload', to: 'repos#add_file', as: 'upload'
  post 'repos/:id/add_directory', to: 'repos#add_directory', as: 'add_directory'
  post 'repos/:id/add_link', to: 'repos#add_link', as: 'add_link'
  delete 'repos/:id/file', to: 'repos#delete_file', as: 'delete_file'
  delete 'repos/:id/directory', to: 'repos#delete_directory', as: 'delete_directory'
  
  get 'login', to: 'sessions#new', as: 'login'
  post 'login', to: 'sessions#create'
  get 'logout', to: 'sessions#destroy', as: 'logout'

  post 'enable_file_viewer', to: 'sessions#enable_file_viewer'
  post 'disable_file_viewer', to: 'sessions#disable_file_viewer'

  get 'file_viewer_settings', to: 'sessions#file_viewer_settings'
  post 'file_viewer_settings', to: 'sessions#save_file_viewer_settings'

  root 'klasses#index'
end
