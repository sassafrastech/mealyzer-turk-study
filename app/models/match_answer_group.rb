class MatchAnswerGroup
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming


  attr_accessor :answers

  def initialize(params)
    params.each {|k,v| instance_variable_set("@#{k}", v)}
    answers.each{ |a| a.init_for_review }
  end

  def answers_by_id
    @answers_by_id ||= answers.index_by(&:id)
  end

  def update_answers(params)
    Rails.logger.debug("lasjkfdslfadlasfk")
    success = true
    params[:answers].each do |id, attribs|
      answer = answers_by_id[id.to_i]
      raise "answer #{id} not found in group" if answer.nil?

      # This is in case all checkboxes were unchecked.
      attribs[:food_groups_update] ||= {}

      answer.assign_attributes(attribs)
      answer.build_answers_changed!

      if answer.save
        Rails.logger.debug("#{answer.component_name}: Save succeeded")
      else
        Rails.logger.debug("Validation failed")
        success = false
      end
    end
    return success
  end
end
