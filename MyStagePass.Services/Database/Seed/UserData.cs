using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MyStagePass.Services.Database.Seed
{
	public static class UserData
	{
		public static void SeedData(this EntityTypeBuilder<User> entity)
		{
			string sampleBase64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/wIAAgUBAO+f4LkAAAAASUVORK5CYII=";

			entity.HasData(
				new User
				{
					UserID = 1,
					FirstName = "Admin",
					LastName = "User",
					Username = "admin",
					Email = "admin@example.com",
					Password = "87uR2UGEwJb+G94YYYqc4IZIbthyTaHA4boQDN5CExA=", //admin123
					Salt = "IhR/4bRJzroO4bcmtgHGkqYUmN1Wla4zV4czkA3g7ms=",
					PhoneNumber = "000000000",
					IsActive = true,
					Image = Convert.FromBase64String(sampleBase64)
				},

				new User
				{
					UserID = 2,
					FirstName = "Dzejla",
					LastName = "Ramovic",
					Username = "dzejla",
					Email = "dzejla@example.com",
					Password = "wVeM+A7xFOWmNz6WUzs23LSzd+Pm7/PplyQ9GpV87Hk=", //dzejla123
					Salt = "pvjWq+VujYdSTol9MA3VVhP6EY+Kql6fYFCBASS+d8M=",
					PhoneNumber = "111222333",
					IsActive = true,
					Image = Convert.FromBase64String(sampleBase64)
				},

				new User
				{
					UserID = 3,
					FirstName = "Ilma",
					LastName = "Karahmet",
					Username = "ilmaak",
					Email = "ilma@example.com",
					Password = "uxK0YxJPz9QLsVfw4ee8fL+dM1uUN8vN6WFPCyOAcqA=", //ilma1234
					Salt = "BqpqvdzJDc8t1l7ZBXd1IRCWTZWSg/59+fEDHpoVWrQ=",
					PhoneNumber = "222333444",
					IsActive = true,
					Image = Convert.FromBase64String(sampleBase64)
				},

				new User
				{
					UserID = 4,
					FirstName = "Jelena",
					LastName = "Rozga",
					Username = "jelena",
					Email = "jelena@example.com",
					Password = "TL7rkXHBNDNC3NPpuVp+h5+SnysyzvjZuqnmmJHcFjM=", //jelena13
					Salt = "I4Pn06A7oNUVQ/kUYqo237If6DFHywUzqb6P5HiHbIU=",
					PhoneNumber = "333444555",
					IsActive = true,
					Image = Convert.FromBase64String(sampleBase64)
				},

				new User
				{
					UserID = 5,
					FirstName = "Toni",
					LastName = "Cetinski",
					Username = "toniii",
					Email = "toni@example.com",
					Password = "mW/8bOiXthVpBSuYPLobPjvy8i+xTfHNmcDqUIlCDU8=", //toni1234
					Salt = "70L4RL1BfNDf3kdFuFnV8CVKa6P0IwCqpBbhGlydWn0=",
					PhoneNumber = "444555666",
					IsActive = true,
					Image = Convert.FromBase64String(sampleBase64)
				},

				new User
				{
					UserID = 6,
					FirstName = "Zeljko",
					LastName = "Samardzic",
					Username = "zeljko",
					Email = "zeljko@example.com",
					Password = "yqgTF438f2Lmh9UVeFJUiwqM9ms4pVlRKExytyEcoLc=", //zeljko123
					Salt = "cSWM+1tJLPyb+F6cK8ZQDBzo6Cw+A0qKIWsXkmnKUxU=",
					PhoneNumber = "555666777",
					IsActive = true,
					Image = Convert.FromBase64String(sampleBase64)
				},
				new User
				{
					UserID = 7,
					FirstName = "Adi",
					LastName = "Sose",
					Username = "adiadi",
					Email = "adi.sose@music.ba",
					Password = "AFrPHkJgGwem4HcBxjOQVIAb4Q28BzVVHX/ZN6Q9xRo=", //adi12345
					Salt = "BT3f8UtxcoBLisQB/FJxwuqqnOay2ljl/QVUEBJvTmI=",
					PhoneNumber = "062100200",
					IsActive = true,
					Image = Convert.FromBase64String(sampleBase64)
				},
				new User
				{
					UserID = 8,
					FirstName = "Mirza",
					LastName = "Selimovic",
					Username = "mirza",
					Email = "mirza.selimovic@music.ba",
					Password = "t65o+TDWMg3wZqvSauac7Za9O+WSYLUCCTZd16LPQ9c=", //mirza123
					Salt = "ND4TT9G7L0CPqEUZSZPt01WwWVfygp8IjBinRgUKpAo=",
					PhoneNumber = "062300400",
					IsActive = true,
					Image = Convert.FromBase64String(sampleBase64)
				},
				new User
				{
					UserID = 9,
					FirstName = "Marija",
					LastName = "Serifovic",
					Username = "marija",
					Email = "marija.serifovic@music.rs",
					Password = "n0UVopmYJy/g6js2r+XAweB02IzjO/y8FsWdqNy/BrY=", //mara1234
					Salt = "x0YMxizLpEYY6lYHkWqcaYw9V+Yyvg83y+Iy10IqLWw=",
					PhoneNumber = "062500600",
					IsActive = true,
					Image = Convert.FromBase64String(sampleBase64)
				},
				new User
				{
					UserID = 10,
					FirstName = "Andjela",
					LastName = "Ignjatovic",
					Username = "breskvica",
					Email = "andjela.ignjatovic@music.rs",
					Password = "ca1n8phe9qcWgzl7zmBl0aJyuvxut+GMkUK+L6pcfkk=", //breskvica
					Salt = "mZzvr89UfKLoIUbL71pQvqThUqsYQ7egDS7A5aRF21g=",
					PhoneNumber = "062888999",
					IsActive = true,
					Image = Convert.FromBase64String(sampleBase64)
				},
				new User
				{
					UserID = 11,
					FirstName = "Selma",
					LastName = "Alagic",
					Username = "selmica",
					Email = "selma@example.com",
					Password = "3norKUP6vaGTTLxYT6z8ViqMTwel5H9VzDJtvv8UXsc=", //selma123
					Salt = "IthWo0ZtwYbd7p5WbFFRhzKQwlPrWpoezX88mm5jVRw=",
					PhoneNumber = "666777888",
					IsActive = true,
					Image = Convert.FromBase64String(sampleBase64)
				},
				new User
				{
					UserID = 12,
					FirstName = "Eda",
					LastName = "Erdem",
					Username = "edaer",
					Email = "eda@example.com",
					Password = "TeYbmcLPN0RiS6SerDD5m48oJE24WAvx009eqCWJK0A=", //eda12345
					Salt = "p4tjDRYIxKl+mM7f+BAEOGwWCOPqIvpJlo5JIoTqKv4=",
					PhoneNumber = "777888999",
					IsActive = true,
					Image = Convert.FromBase64String(sampleBase64)
				},
				new User
				{
					UserID = 13,
					FirstName = "Tesa",
					LastName = "Zahirovic",
					Username = "tesaza",
					Email = "tesa@example.com",
					Password = "5DFY+n7My58tZKF07JOHUu8qJjgTkM7r+hRYKT3qRQQ=", //tesa1234
					Salt = "c10TpCTlVieWsdcohjgjLNfMA9KgWwybFQ+3U5o9oUM=",
					PhoneNumber = "888999000",
					IsActive = true,
					Image = Convert.FromBase64String(sampleBase64)
				},
				new User
				{
					UserID = 14,
					FirstName = "Amar",
					LastName = "Hadzic",
					Username = "amarh",
					Email = "amar.hadzic@example.com",
					Password = "/fq/ZbEHiyr+6qHRPVl8fFYkHOBMowMiRfUH3Of3x1E=",
					Salt = "FCzcfULb99fc3b7Qjy+heBwjPKhOmNqedHHS3JjGIfI=",
					PhoneNumber = "061111222",
					IsActive = true,
					Image = Convert.FromBase64String(sampleBase64)
				},
				new User
				{
					UserID = 15,
					FirstName = "Lejla",
					LastName = "Besic",
					Username = "lejla",
					Email = "lejla.besic@example.com",
					Password = "7erFCNVSn07ADEKFvD1GGV3nuZNEcpCUYwt7qLN3nkQ=", //lejla123
					Salt = "l88utjIAbSXngCFU3vPPYI+6sP7WdmSXeXpzqcS2qdM=",
					PhoneNumber = "061333444",
					IsActive = true,
					Image = Convert.FromBase64String(sampleBase64)
				},
				new User
				{
					UserID = 16,
					FirstName = "Senad",
					LastName = "Alagic",
					Username = "senad",
					Email = "senad.alagic@example.com",
					Password = "963sbRGs1agjPtAZPUtFAFdS3c84DlPA3FFRsVR2/3A=", //senad123
					Salt = "Oxh+ozoEh9xY6lApHpi3ICxYcBdqNSpI+dikiXpjZqw=",
					PhoneNumber = "061777888",
					IsActive = true,
					Image = Convert.FromBase64String(sampleBase64)
				}
			);
		}
	}
}