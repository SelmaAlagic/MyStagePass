using MyStagePass.Model;
using MyStagePass.Model.SearchObjects;
using MyStagePass.WebAPI.Controllers;


namespace MyStagePass.Services
{
	public class DummyUserService:IUserService
	{
		public virtual List<User> Get(UserSearchObject search)
		{
			List<User> users = new List<User>();
			users.Add(new User()
			{
				UserID = 1,
				FirstName = "Selma",
				LastName = "Alagic",
				Username = "Semka",
				Email = "selma@gmail.com",
				Password = "selma123"
			});

			var quaryable = users.AsQueryable();

			if (!string.IsNullOrWhiteSpace(search?.FirstName))
			{
				quaryable = quaryable.Where(x => x.FirstName.ToLower() == search.FirstName.ToLower());
			}
			if (!string.IsNullOrWhiteSpace(search?.FTS))
			{
				quaryable = quaryable.Where(x => x.FirstName.ToLower().Contains(search.FTS, StringComparison.CurrentCultureIgnoreCase) || (x.PhoneNumber!=null && x.PhoneNumber.ToLower().Contains(search.FTS.ToLower())));

			}

			return quaryable.ToList();
		}
		public virtual User Get(int Id)
		{
			return new User()
			{

				UserID = 1,
				FirstName = "Selma",
				LastName = "Alagic",
				Username = "Semka",
				Email = "selma@gmail.com",
				Password = "selma123"

			};

		}
	}
}
