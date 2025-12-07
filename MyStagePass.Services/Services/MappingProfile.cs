using AutoMapper;
using MyStagePass.Model.Models;
using MyStagePass.Model.Requests;

namespace MyStagePass.Services.Services
{
	public class MappingProfile : Profile
	{
		public MappingProfile()
		{
			CreateMap<Database.Admin, Admin>();
			CreateMap<Database.User, User>();
			CreateMap<Model.Requests.AdminInsertRequest, Database.User>();
			CreateMap<Model.Requests.AdminInsertRequest, Database.Admin>();
			CreateMap<Model.Requests.AdminUpdateRequest, Database.User>().ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));
			CreateMap<Model.Requests.AdminUpdateRequest, Database.Admin>().ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));

			CreateMap<Database.Customer, Customer>();
			CreateMap<Model.Requests.CustomerInsertRequest, Database.User>();
			CreateMap<Model.Requests.CustomerInsertRequest, Database.Customer>();
			CreateMap<Model.Requests.CustomerUpdateRequest, Database.User>().ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));
			CreateMap<Model.Requests.CustomerUpdateRequest, Database.Customer>().ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));

			CreateMap<Database.Performer, Performer>();
			CreateMap<Model.Requests.PerformerInsertRequest, Database.User>();
			CreateMap<Model.Requests.PerformerInsertRequest, Database.Performer>();
			CreateMap<Model.Requests.PerformerUpdateRequest, Database.User>().ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));
			CreateMap<Model.Requests.PerformerUpdateRequest, Database.Performer>().ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));

			CreateMap<Database.Event, Event>();
			CreateMap<Model.Requests.EventInsertRequest, Database.Event>();
			CreateMap<Model.Requests.EventUpdateRequest, Database.Event>().ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));

			CreateMap<Database.Location, Model.Models.Location>().ForMember(dest => dest.Events, opt => opt.MapFrom(src => src.Events.Where(e => e.EventDate >= DateTime.Now).ToList()));
			CreateMap<LocationInsertRequest, Database.Location>();
			CreateMap<LocationUpdateRequest, Database.Location>().ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));

			CreateMap<Database.Status, Model.Models.Status>().ForMember(dest => dest.Events, opt => {opt.MapFrom(src => src.Events.Select(e => new Model.Models.Event{EventID = e.EventID,
					EventName = e.EventName}).ToList());
					opt.ExplicitExpansion();});

			CreateMap<Database.Ticket, Model.Models.Ticket>();

			CreateMap<Database.Review, Model.Models.Review>();
			CreateMap<ReviewInsertRequest, Database.Review>();

			CreateMap<Database.Purchase, Model.Models.Purchase>();

			CreateMap<Database.CustomerFavoriteEvent, Model.Models.CustomerFavoriteEvent>();
			CreateMap<CustomerFavoriteEventInsertRequest, Database.CustomerFavoriteEvent>();

			CreateMap<Database.City, Model.Models.City>();
			CreateMap<Database.Country, Model.Models.Country>();

			CreateMap<Database.Notification, Model.Models.Notification>();
			CreateMap<NotificationInsertRequest, Database.Notification>();

			CreateMap<Database.Performer, Model.Models.Performer>().ForMember(dest => dest.Genres, opt => opt.MapFrom(src => src.Genres.Select(pg => pg.Genre.Name).ToList()));
			CreateMap<Database.Genre, Model.Models.Genre>().ForMember(dest => dest.Performers, opt => opt.MapFrom(src => src.Performers.Select(pg => pg.Performer.ArtistName).ToList()));
		}
	}
}