namespace MyStagePass.Model.Models
{
    public class Admin
    {
        public int AdminID { get; set; }
        public int UserID { get; set; }
        public virtual User User { get; set; } = null!;
    }
}