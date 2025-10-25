namespace MyStagePass.Model
{
	public class Status //kod eventa ended ili upcoming i rejected/approved/pending, kod performera rejected/approved, kod uesra active/unactive/blocked ili sta vec
	{
		public int StatusID {  get; set; }
		public string? StatusName {  get; set; }
	}
}
