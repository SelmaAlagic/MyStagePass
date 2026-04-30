using System.Net.Mail;
using System.Net;
using Newtonsoft.Json;

namespace MyStagePass.Subscriber
{
	public class EmailService
	{
		private readonly string _smtpServer;
		private readonly int _smtpPort;
		private readonly string _fromMail;
		private readonly string _password;
		private readonly bool _enableSsl;

		public EmailService()
		{
			_smtpServer = Environment.GetEnvironmentVariable("SMTP_SERVER")
				?? throw new InvalidOperationException("SMTP_SERVER is not configured.");
			_smtpPort = int.Parse(Environment.GetEnvironmentVariable("SMTP_PORT") ?? "587");
			_fromMail = Environment.GetEnvironmentVariable("SMTP_USERNAME")
				?? throw new InvalidOperationException("SMTP_USERNAME is not configured.");
			_password = Environment.GetEnvironmentVariable("SMTP_PASSWORD")
				?? throw new InvalidOperationException("SMTP_PASSWORD is not configured.");
			_enableSsl = bool.Parse(Environment.GetEnvironmentVariable("SMTP_USE_SSL") ?? "true");
		}

		public void SendEmail(string message)
		{
			var emailData = JsonConvert.DeserializeObject<EmailModel>(message)
				?? throw new InvalidOperationException("Could not deserialize email message.");

			using var mailMessage = new MailMessage
			{
				From = new MailAddress(_fromMail),
				Subject = emailData.Subject,
				Body = emailData.Content,
			};
			mailMessage.To.Add(emailData.Recipient);

			using var smtpClient = new SmtpClient
			{
				Host = _smtpServer,
				Port = _smtpPort,
				Credentials = new NetworkCredential(_fromMail, _password),
				EnableSsl = _enableSsl
			};

			smtpClient.Send(mailMessage);
			Console.WriteLine($"[*] Email sent to {emailData.Recipient} | Subject: {emailData.Subject}");
		}
	}
}