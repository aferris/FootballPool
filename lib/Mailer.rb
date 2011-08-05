class Mailer
  def mail(recipients, subject, body)
  
    @from = 'aferris@homisco.com'
    @recipients = recipients
    @subject = subject
    @body = body
  end
  
  def self.send_mail(recipients, subject, body)
    ActionMailer::RequestMailer::deliver_mail(recipients, subject, body)
  end
end