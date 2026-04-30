public interface ICurrentUserService
{
	int GetUserId();      
	int GetCustomerId(); 
	int GetPerformerId(); 
	string GetRole();
	bool IsAdministrator();
}