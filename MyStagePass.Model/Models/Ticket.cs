using QRCoder;

namespace MyStagePass.Model.Models
{
	public class Ticket
	{
		public int TicketID { get; set; }
		public int Price { get; set; }
		public int EventID { get; set; }
		public virtual Event Event { get; set; } = null!;
		public int PurchaseID { get; set; }
		public virtual Purchase Purchase { get; set; } = null!;
		public Event.TicketType TicketType { get; set; }
		public byte[]? QRCodeData { get; set; } 
		public bool IsDeleted { get; set; } = false;
		public void GenerateQRCode(string text)
		{
			using (QRCodeGenerator qrGenerator = new QRCodeGenerator())
			{
				QRCodeData qrCodeData = qrGenerator.CreateQrCode(text, QRCodeGenerator.ECCLevel.L);
				using (PngByteQRCode qrCode = new PngByteQRCode(qrCodeData))
				{
					QRCodeData = qrCode.GetGraphic(20);
				}
			}
		}
		public string GetTicketTypeName()
		{
			return TicketType switch
			{
				Event.TicketType.Regular => "Regular",
				Event.TicketType.Vip => "VIP",
				Event.TicketType.Premium => "Premium",
				_ => "Unknown"
			};
		}
	}
}