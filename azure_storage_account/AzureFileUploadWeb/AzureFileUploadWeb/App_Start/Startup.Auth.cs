using System;
using Microsoft.AspNet.Identity;
using Microsoft.AspNet.Identity.Owin;
using Microsoft.Owin;
using Microsoft.Owin.Security.Cookies;
using Microsoft.Owin.Security.Google;
using Owin;
using AzureFileUploadWeb.Models;

namespace AzureFileUploadWeb
{
    public partial class Startup
    {
        // 인증 구성에 대한 자세한 내용은 http://go.microsoft.com/fwlink/?LinkId=301864를 참조하십시오.
        public void ConfigureAuth(IAppBuilder app)
        {
                   
            app.UseExternalSignInCookie(DefaultAuthenticationTypes.ExternalCookie);

            // 응용 프로그램에서 2단계 인증 프로세스의 두 번째 단계를 확인할 때 사용자 정보를 일시적으로 저장하도록 설정합니다.
            app.UseTwoFactorSignInCookie(DefaultAuthenticationTypes.TwoFactorCookie, TimeSpan.FromMinutes(5));

            // 응용 프로그램에서 전화나 전자 메일 같은 두 번째 로그인 확인 단계를 기억하도록 설정합니다.
            // 이 옵션을 선택하면 사용자가 로그인한 장치에서 로그인 프로세스의 두 번째 확인 단계를 기억합니다.
            // 로그인할 때의 [사용자 이름 및 암호 저장] 옵션과 유사합니다.
            app.UseTwoFactorRememberBrowserCookie(DefaultAuthenticationTypes.TwoFactorRememberBrowserCookie);

            // 타사 로그인 공급자로 로그인할 수 있으려면 다음 줄의 주석 처리를 제거합니다.
            //app.UseMicrosoftAccountAuthentication(
            //    clientId: "",
            //    clientSecret: "");

            //app.UseTwitterAuthentication(
            //   consumerKey: "",
            //   consumerSecret: "");

            //app.UseFacebookAuthentication(
            //   appId: "",
            //   appSecret: "");

            //app.UseGoogleAuthentication(new GoogleOAuth2AuthenticationOptions()
            //{
            //    ClientId = "",
            //    ClientSecret = ""
            //});
        }
    }
}