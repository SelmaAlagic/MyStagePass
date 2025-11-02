using QRCoder;
using System.Drawing;

namespace MyStagePass.Services.Database
{
	public class Ticket
	{
		public int TicketID { get; set; }
		public float Price {  get; set; }
		public int EventID {  get; set; }
		public virtual Event Event { get; set; } = null!;
		public int TicketTypeID {  get; set; }
		public virtual TicketType TicketType { get; set; }=null!;
		public int PurchaseID { get; set; }
		public virtual Purchase Purchase { get; set; } = null!;
		public byte[]? QRCodeData { get; set; } //QR kao slika

		internal static decimal Sum(Func<object, object> value)
		{
			throw new NotImplementedException();
		}

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

	}
}
