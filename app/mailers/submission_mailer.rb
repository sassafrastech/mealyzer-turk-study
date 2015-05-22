class SubmissionMailer < ActionMailer::Base
  default from: "mealyzer@sassafras.coop"

  def nutrition_request(mobile_submission)
    @mobile_submission = mobile_submission
    mail(to: "tomsmyth@gmail.com", subject: "Mealyzer: New nutritional evaluation request")
  end
end
