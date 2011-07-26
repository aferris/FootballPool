class RequestMailer < ActionMailer::Base
  def mail(recipients, subject, body)

    @from = 'aferris@homisco.com'
    @recipients = recipients
    @subject = subject
    @body = body
  end
end
