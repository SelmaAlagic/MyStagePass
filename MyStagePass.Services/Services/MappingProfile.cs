using AutoMapper;
using MyStagePass.Model.Models;

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
		}
	}
}
