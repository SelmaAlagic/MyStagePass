using MyStagePass.Model;
using MyStagePass.Model.SearchObjects;
using MyStagePass.WebAPI.Controllers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyStagePass.Services
{
	public class UserService:IUserService
	{
		public List<User> Get(UserSearchObject search)
		{
			throw new NotImplementedException();
		}
		public User Get(int Id)
		{ 
			throw new NotImplementedException(); 
		}


		//public virtual List<User> Get()
		//{
		//	List<User> users = new List<User>();
		//	users.Add(new User()
		//	{
		//		UserID = 1,
		//		FirstName = "Selma",
		//		LastName = "Alagic",
		//		Username = "Semka",
		//		Email = "selma@gmail.com",
		//		Password = "selma123"
		//	});
		//	return users;
		//}
		//public virtual User Get(int Id)
		//{
		//	return new User()
		//	{

		//		UserID = 1,
		//		FirstName = "Selma",
		//		LastName = "Alagic",
		//		Username = "Semka",
		//		Email = "selma@gmail.com",
		//		Password = "selma123"

		//	};

		//}   prvo smo ovo implementiral pa smo posli raditi neke servise, sad mi nije jasno kod dependencyja, on sluzi da ne pravi sam svoje zavisnosti nego da mu budu dodijeljene
	} 
}
