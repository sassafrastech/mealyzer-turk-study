class SubmissionMailer < ActionMailer::Base
  default from: "mealyzer@sassafras.coop"

  def nutrition_request(mobile_submission)
    @mobile_submission = mobile_submission
    # put in emails here
    mail(to: "jpdimond@gmail.com, om2196@cumc.columbia.edu, ejd14@cumc.columbia.edu", subject: "Mealyzer: New nutritional evaluation request")
  end
end
