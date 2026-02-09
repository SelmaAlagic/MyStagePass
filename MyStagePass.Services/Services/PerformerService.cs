using AutoMapper;
using Microsoft.EntityFrameworkCore;
using MyStagePass.Model.Helpers;
using MyStagePass.Model.Requests;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Database;
using MyStagePass.Services.Helpers;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.Services.Services
{
	public class PerformerService : BaseCRUDService<Model.Models.Performer, Performer, PerformerSearchObject, PerformerInsertRequest, PerformerUpdateRequest>, IPerformerService
	{
		private readonly INotificationService _notificationService;
		private IRabbitMQProducer _rabbitMQProducer;

		public PerformerService(MyStagePassDbContext context, IMapper mapper, INotificationService notificationService, IRabbitMQProducer rabbitMQProducer) : base(context, mapper)
		{
			_notificationService = notificationService;
			_rabbitMQProducer=rabbitMQProducer;
		}

		public override async Task BeforeInsert(Performer entity, PerformerInsertRequest insert)
		{
			if (insert.Password != insert.PasswordConfirm)
				throw new UserException("Password and confirmation do not match.");

			if (await _context.Users.AnyAsync(u => u.Username == insert.Username))
				throw new UserException("Username already exists.");

			if (await _context.Users.AnyAsync(u => u.Email == insert.Email))
				throw new UserException("Email already exists.");

			User user = _mapper.Map<User>(insert);
			entity.User = user;
			entity.User.Salt = PasswordHelper.GenerateSalt();
			entity.User.Password = PasswordHelper.GenerateHash(entity.User.Salt, insert.Password);

			entity.Genres = new List<PerformerGenre>();
			if (insert.GenreIds != null && insert.GenreIds.Count > 0)
			{
				var distinctGenreIds = insert.GenreIds.Distinct().ToList();
				var genresFromDb = await _context.Genres.Where(g => distinctGenreIds.Contains(g.GenreID)).ToListAsync();

				foreach (var genreId in distinctGenreIds)
				{
					var genreEntity = genresFromDb.FirstOrDefault(g => g.GenreID == genreId);
					if (genreEntity == null)
						throw new UserException($"Genre with ID {genreId} does not exist.");

					entity.Genres.Add(new PerformerGenre
					{
						GenreID = genreId,
						Performer = entity,
						Genre = genreEntity
					});
				}
			}

			await _notificationService.NotifyUser(1, $"New performer '{insert.FirstName} {insert.LastName}' is waiting for approval!");
		}

		public override IQueryable<Performer> AddInclude(IQueryable<Performer> query, PerformerSearchObject? search = null)
		{
			if (search.isUserIncluded == true)
			{
				query = query.Include("User");
			}

			query = query.Include(p=> p.Events).Include(p=>p.User)
						 .Include(p => p.Genres).ThenInclude(pg => pg.Genre);

			if (!string.IsNullOrWhiteSpace(search?.searchTerm))
			{
				string term = search.searchTerm.ToLower();
				query = query.Where(p =>
					(p.ArtistName != null && p.ArtistName.ToLower().StartsWith(term)) ||
					(p.User.FirstName != null && p.User.FirstName.ToLower().StartsWith(term)) ||
					(p.User.LastName != null && p.User.LastName.ToLower().StartsWith(term)));
			}

			if (search?.IsPending == true)
			{
				query = query.Where(p => p.IsApproved == null);
			}
			else if (search?.IsApproved != null)
			{
				query = query.Where(p => p.IsApproved == search.IsApproved);
			}

			if (search?.GenreID != null)
			{
				query = query.Where(p => p.Genres.Any(pg => pg.GenreID == search.GenreID.Value));
			}

			return base.AddInclude(query, search);
		}

		public async Task<Model.Models.Performer> ApprovePerformer(int performerId, bool isApproved)
		{
			var entity = await _context.Performers
				.Include(p => p.User)
				.FirstOrDefaultAsync(p => p.PerformerID == performerId);

			if (entity == null)
				throw new UserException("Performer not found.");

			entity.IsApproved = isApproved;

			var emailModel = new EmailModel
			{
				Sender = "noreply@mystagepass.com",
				Recipient = entity.User.Email,
				Subject = isApproved ? "Your performer account has been approved"
							: "Your performer account has been rejected",
				Content = isApproved
		   ? $"Hello {entity.User.FirstName},\n\nYour performer account has been approved! You can now access all platform features."
		   : $"Hello {entity.User.FirstName},\n\nUnfortunately, your performer account has been rejected. Please contact support for more information."
			};

			_rabbitMQProducer.SendMessage(emailModel);

			await _context.SaveChangesAsync();

			return _mapper.Map<Model.Models.Performer>(entity);
		}

		public override async Task<Model.Models.Performer> Update(int id, PerformerUpdateRequest update)
		{
			if (!string.IsNullOrEmpty(update.Password) || !string.IsNullOrEmpty(update.PasswordConfirm))
			{
				if (update.Password != update.PasswordConfirm)
					throw new UserException("Password and confirmation do not match.");
			}

			var set = _context.Set<Performer>();
			var entity = await set.Include(c => c.User).FirstOrDefaultAsync(c => c.PerformerID == id);
			_mapper.Map(update, entity?.User);
			_mapper.Map(update, entity);
			await _context.SaveChangesAsync();
			return _mapper.Map<Model.Models.Performer>(entity);
		}

		public async Task<Model.Models.Performer> UpdateBaseUser(int id, PerformerUpdateRequest update)
		{
			var set = _context.Set<Performer>();
			var entity = await set.Include(c => c.User).FirstOrDefaultAsync(c => c.PerformerID == id);
			_mapper.Map(update, entity?.User);
			await _context.SaveChangesAsync();
			return _mapper.Map<Model.Models.Performer>(entity);
		}

		public override async Task<PagedResult<Model.Models.Performer>> Get(PerformerSearchObject? search = null)
		{
			var result = await base.Get(search);

			foreach (var performer in result.Result)
			{
				performer.AverageRating = performer.Events
					.Where(e => e.RatingCount > 0)
					.Select(e => e.RatingAverage)
					.DefaultIfEmpty(0)
					.Average();
			}
			return result;
		}
	}
}