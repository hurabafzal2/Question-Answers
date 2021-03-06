ActiveAdmin.register Question do
  menu priority: 15
  permit_params :question, :answer, :technology_id, :marks, :status
  #filters
  filter :id, :label=> "Search By Question"
  filter :status
  filter :technology_id, :as => :check_boxes, multiple: true, :collection => proc {(Technology.all).map{|c| [c.name,c.id]}}
  # scope("Questions") { |scope| scope.where(id: Question.pluck(:id).shuffle[1..10])}
  # scope(" Or Questions") { |scope| scope.where(id: Question.pluck(:id).shuffle[1..15])}
  filter :marks
  # member_action
  member_action :approve, method: :post, only: :index do
  end
  action_item :view, only: :index do
    link_to 'Select Questions To Print', question_filter_form_path
  end

  #show page
  show do
    attributes_table do
      row (:question) { |t| strip_tags(t.question) }
      row (:answer) { |t| strip_tags(t.answer) }
      row :technology
      row :created_at
      row :updated_at
      row :marks
      row :status
    end
  end
  # form
  form do |f|
    if current_user.type != "Admin"
     f.inputs do
        f.input :technology_id, :as => :select, :collection => Technology.all.map {|u| [u.name, u.id]}, :include_blank => true, :prompt => 'Select Technology'
        f.label :question, class: "label-margin"
        f.input :question, as: :quill_editor, label: false, input_html: {data: { options: { modules: { toolbar: [
          ['bold', 'italic', 'underline'],
          ['code-block'],
          [{ 'list': 'ordered' }, { 'list': 'bullet'}],
          [{ 'align': []}],
          [{ 'size': [] }],
          ['image'],
          [ 'clean' ]] } } } }
          f.label :answer, class: "label-margin"
        f.input :answer, as: :quill_editor, label: false, input_html: { data: { options: { modules: { toolbar: [
          ['bold', 'italic', 'underline'],
          ['code-block'],
          [{ 'list': 'ordered' }, { 'list': 'bullet'}],
          [{ 'align': []}],
          [{ 'size': [] }],
          ['image'],
          [ 'clean' ]] } } } }
          f.input :marks
      end
      f.actions
    else
      f.inputs do
        f.input :technology_id, :as => :select, :collection => Technology.all.map {|u| [u.name, u.id]}, :include_blank => true, :prompt => 'Select Technology'
        f.label :question, class: "label-margin"
        f.input :question, as: :quill_editor, label: false, input_html: {data: { options: { modules: { toolbar: [
          ['bold', 'italic', 'underline'],
          ['code-block'],
          [{ 'list': 'ordered' }, { 'list': 'bullet'}],
          [{ 'align': []}],
          [{ 'size': [] }],
          ['image'],
          [ 'clean' ]] } } } }
          f.label :answer, class: "label-margin"
        f.input :answer, as: :quill_editor, label: false, input_html: { data: { options: { modules: { toolbar: [
          ['bold', 'italic', 'underline'],
          ['code-block'],
          [{ 'list': 'ordered' }, { 'list': 'bullet'}],
          [{ 'align': []}],
          [{ 'size': [] }],
          ['image'],
          [ 'clean' ]] } } } }
        f.input :marks
        f.input :status
      end
      f.actions 
    end 
  end
  #index
  index :download_links=> [:pdf] do
    selectable_column
      column (:question) { |t| strip_tags(t.question).truncate(50)} 
      if current_user.type == "Admin" 
        column (:answer) { |t| strip_tags(t.answer).truncate(50)} 
      end
      column :technology
      column :marks, sortable: false
      if current_user.admin?
        column :status do |s|
          if s.status == false
          link_to('Not Approved', approve_admin_question_path(s), class: "view_link member_link", method: :post)
          else
            s.status
          end
        end
        else
         column :status
      end
       actions
  end
  #controller
  controller do
   
    def scoped_collection 
      if current_user.type == "Viewer"
        Question.where(status: true)
      else
        Question.all
      end
    end
    def approve
      question = Question.find(params[:id])    
      question.status = true
      if question.save
        resource.status = true
        resource.save
        redirect_to admin_questions_path, notice: 'Question Approved!'
      end  
    end
    def pdf_content
    end
    def download_pdf
      respond_to do |format|
        format.html 
        format.pdf do
          render pdf: 'mypdf', template: 'admin/questions/pdf_content'
        end
      end
    end
  end
end
