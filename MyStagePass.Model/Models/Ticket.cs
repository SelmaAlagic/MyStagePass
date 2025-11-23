using QRCoder;
using System.Drawing;
using System.IO;

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
		public byte[]? QRCodeData { get; set; } //QR kao slika
		public bool IsDeleted { get; set; } = false;
		public void GenerateQRCode(string text)
		{
			using (QRCodeGenerator qrGenerator = new QRCodeGenerator())
			{
				QRCodeData qrCodeData = qrGenerator.CreateQrCode(text, QRCodeGenerator.ECCLevel.Q);
				using (QRCode qrCode = new QRCode(qrCodeData))
				using (Bitmap qrBitmap = qrCode.GetGraphic(20))
				using (MemoryStream ms = new MemoryStream())
				{
					qrBitmap.Save(ms, System.Drawing.Imaging.ImageFormat.Png);
					QRCodeData=ms.ToArray();
				}
			}
		}

		public Bitmap GetQRCodeBitmap()
		{
			if (QRCodeData == null) return null;
			using (var ms = new MemoryStream(QRCodeData))
			{
				return new Bitmap(ms);
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