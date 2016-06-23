using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(AzureFileUploadWeb.Startup))]
namespace AzureFileUploadWeb
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureAuth(app);
        }
    }
}
