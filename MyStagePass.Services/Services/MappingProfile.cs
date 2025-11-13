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
			CreateMap<Model.Requests.PerformerInsetRequest, Database.User>();
			CreateMap<Model.Requests.PerformerInsetRequest, Database.Performer>();
			CreateMap<Model.Requests.PerformerUpdateRequest, Database.User>().ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));
			CreateMap<Model.Requests.PerformerUpdateRequest, Database.Performer>().ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));

			CreateMap<Database.Event, Event>();
			CreateMap<Model.Requests.EventInsertRequest, Database.Event>();
			CreateMap<Model.Requests.EventUpdateRequest, Database.Event>().ForAllMembers(opts => opts.Condition((src, dest, srcMember) => srcMember != null));

			CreateMap<Database.Location, Model.Models.Location>();
			CreateMap<Database.Performer, Model.Models.Performer>();
			CreateMap<Database.Status, Model.Models.Status>();
			CreateMap<Database.Ticket, Model.Models.Ticket>();
			CreateMap<Database.Review, Model.Models.Review>();
			CreateMap<Database.CustomerFavoriteEvent, Model.Models.CustomerFavoriteEvent>();

		}
	}
}
