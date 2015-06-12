class SubmissionMailer < ActionMailer::Base
  default from: Env.mealyzer_email_submission_from

  def nutrition_request(mobile_submission)
    @mobile_submission = mobile_submission
    mail(to: Env.mealyzer_email_submission_to.split(','), subject: "Mealyzer: New nutritional evaluation request")
  end
end
