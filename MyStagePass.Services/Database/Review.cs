namespace MyStagePass.Services.Database
{
    public class Review
    {
        public int ReviewID { get; set; }
        public int CustomerID { get; set; }
        public virtual Customer Customer { get; set; } = null!;
        public int EventID { get; set; }
        public virtual Event Event { get; set; } = null!;
        public int RatingValue { get; set; }
        public DateTime CreatedAt { get; set; }
    }
} 