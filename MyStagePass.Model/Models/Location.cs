using System.Collections.Generic;

namespace MyStagePass.Model.Models
{
    public class Location
    {
        public int LocationID { get; set; }
        public string LocationName { get; set; }
        public int Capacity { get; set; }
        public string Address { get; set; }
        public int CityID { get; set; }
        public virtual City City { get; set; } = null!;
        public virtual ICollection<Event> Events { get; set; } = new List<Event>();

    }
}
