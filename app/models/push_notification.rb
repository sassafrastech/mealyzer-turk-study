require 'houston'

class PushNotification
  include ActiveModel::Model

  @@APN = Houston::Client.production
  @@APN.certificate = File.read Env.mealyzer_push_notification_cert_pem

  def self.send(token)
    Rails.logger.debug("about to send token")

    Rails.logger.debug(@@APN)
    Rails.logger.debug(@@APN.certificate)

    notification = Houston::Notification.new(device: token)
    notification.alert = "Your dietician evaluated your meal! Click here to view it."
    notification.badge = 1
    notification.sound = "default"
    notification.category = "INVITE_CATEGORY"
    notification.content_available = true

    @@APN.push(notification)
    Rails.logger.debug("sent it")

    Rails.logger.debug("Error: #{notification.error}.") if notification.error
  end

end
