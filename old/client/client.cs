using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Web.Script.Serialization;

namespace Logger
{
	class Program
	{
		static void Main(string[] args)
		{
			foreach (var i in Enumerable.Range(0, 50))
			{

				string URI = "http://localhost:2212/logger/log";
				var httpWebRequest = (HttpWebRequest)WebRequest.Create(URI);
				httpWebRequest.ContentType = "application/json";
				httpWebRequest.Method = "POST";

				using (var streamWriter = new StreamWriter(httpWebRequest.GetRequestStream()))
				{
					//string json = new JavaScriptSerializer().Serialize(new
					//{
					//	user = "Foo",
					//	password = "Baz"
					//});
					string json = new JavaScriptSerializer().Serialize(new object []
					{
						"Foo","Baz","lol","loa", new { Go= new []{ "1","2","3","4" }, YEY= new { l="a", s="zxc" } }
					});
					streamWriter.Write(json);
					streamWriter.Flush();
					streamWriter.Close();

					var httpResponse = (HttpWebResponse)httpWebRequest.GetResponse();
					using (var streamReader = new StreamReader(httpResponse.GetResponseStream()))
					{
						var result = streamReader.ReadToEnd();
						Console.WriteLine(result);
					}
				}

				//Console.ReadLine();
			}
		}

	}
}
