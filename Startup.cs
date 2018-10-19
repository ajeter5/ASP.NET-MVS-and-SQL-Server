using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(DeveloperInterview.Website.Startup))]
namespace DeveloperInterview.Website
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureAuth(app);
        }
    }
}
