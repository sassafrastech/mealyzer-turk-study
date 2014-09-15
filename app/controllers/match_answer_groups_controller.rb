class MatchAnswerGroupsController < ApplicationController

  def edit
    @match_answer_group = MatchAnswerGroup.new(:answers => MatchAnswer.last_five(current_user))
  end

  def update
    group_params = params.require('match_answer_group').permit!
    @match_answer_group = MatchAnswerGroup.new(:answers => MatchAnswer.last_five(current_user))
    if @match_answer_group.update_answers(group_params)
      redirect_to new_match_answer_path
    else
      render :edit
    end
  end

end
