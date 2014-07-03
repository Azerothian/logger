using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Reflection;
using System.Runtime.Serialization;
using System.Text;
using System.Web;
using System.Web.Script.Serialization;

namespace Logger
{
	public class Logger
	{
		public static void Log(string app = "sitecore", string component = "", object message = null)
		{
			//SendExceptionEmail(error);
			LogPost lp = new LogPost();
			lp.application = app;
			lp.component = component;
			lp.message = new LogMessage()
			{
				//Data = GetObjectData(message),
			};
			SendToCollector(lp);
		}


		public static void SendErrorLog()
		{
			foreach (var error in HttpContext.Current.AllErrors)
			{
				LogPost lp = new LogPost();
				lp.application = "sitecore";
				lp.component = "globalerror";
				lp.message = new LogMessage()
				{
					//Data = GetObjectData(error),
				};
				SendToCollector(lp);
			}
		}

		public static ObjectData GetObjectData(object o)
		{
			ObjectData extracted = null;
			if (o is ObjectData)
			{
				extracted = o as ObjectData;
			}
			else
			{
				extracted = ExtractObjectData(o, 4);
			}
			return extracted;
		}
		public static ObjectData ExtractObjectData(object o, int levellimit)
		{
			var data = new ObjectData();
			ExtractObjectData(o, 0, levellimit, ref data);
			return data;
		}


		public static void ExtractObjectData(object obj, int priorlevel, int levellimit, ref ObjectData data)
		{
			try
			{
				var currentlevel = priorlevel + 1;

				if (currentlevel > levellimit)
					return;

				if (obj != null)
				{
					Type tObj = obj.GetType();
					if (tObj.IsPublic || tObj.IsNestedPublic)
					{
						data.Visibility = "Public";
					}
					else
					{
						data.Visibility = "Private";

					}
					data.Type = tObj.FullName;
					if (tObj.IsPrimitive || tObj.IsEnum || tObj.ToString() == "System.String")
					{
						data.Value = obj.ToString();
					}
					else if (tObj.IsArray)
					{
						data.Data = new List<ObjectData>();
						foreach (var s in (Array)obj)
						{
							ObjectData vd = new ObjectData();
							ExtractObjectData(s, currentlevel, levellimit, ref vd);
							data.Data.Add(vd);
						}
					}
					else
					{
						data.Data = new List<ObjectData>();

						// var fields = tObj.GetFields(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance); // Obtain all fields
						var fields = tObj.GetFields(BindingFlags.Public | BindingFlags.Instance); // Obtain all  public fields
						foreach (var field in fields) // Loop through fields
						{
							var tField = field.GetType();
							ObjectData vd = new ObjectData();
							if (tField.IsPrimitive || tField.IsEnum)
							{
								vd.Value = field.ToString();
							}
							else
							{
								ExtractObjectData(field.GetValue(obj), currentlevel, levellimit, ref vd);
								vd.Name += " " + field.Name;
							}
							data.Data.Add(vd);
						}

						//var props = tObj.GetProperties(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance);
						var props = tObj.GetProperties(BindingFlags.Public | BindingFlags.Instance);
						foreach (var prop in props)
						{
							ObjectData vd = new ObjectData();
							var tProp = prop.GetType();
							if (tProp.IsPrimitive || tProp.IsEnum)
							{
								vd.Value = prop.ToString();
							}
							else
							{
								var val = prop.GetValue(obj, null);
								ExtractObjectData(val, currentlevel, levellimit, ref vd);
								vd.Name += " " + prop.Name;
							}

							data.Data.Add(vd);
						}
					}
				}
			}
			catch (Exception)
			{
			}
		}


		public static void SendToCollector(LogPost message)
		{
			try
			{
				var httpWebRequest = (HttpWebRequest)WebRequest.Create(ApplicationSettings.Error.LogCollector);
				httpWebRequest.ContentType = "application/json";
				httpWebRequest.Method = "POST";
				using (var streamWriter = new StreamWriter(httpWebRequest.GetRequestStream()))
				{
					string json = new JavaScriptSerializer().Serialize(message);
					streamWriter.Write(json);
					streamWriter.Flush();
					streamWriter.Close();

					using (var httpResponse = (HttpWebResponse)httpWebRequest.GetResponse())
					{
						using (var streamReader = new StreamReader(httpResponse.GetResponseStream()))
						{
							var result = streamReader.ReadToEnd();
						}
					}
				}
			}
			catch (Exception ex)
			{
				ErrorHelper.SendExceptionEmail(ex);
			}
		}


	}
	[Serializable]
	public class LogPost
	{
		public string application { get; set; }
		public string component { get; set; }
		public DateTime timestamp { get { return DateTime.Now; } }
		public LogMessage message { get; set; }
	}
	[Serializable]
	public class LogMessage
	{
		public SitecoreDetails Sitecore
		{
			get
			{
				return new SitecoreDetails();
			}
		}
		public WebDetails Web
		{
			get
			{
				return new WebDetails();
			}
		}
	}


	[Serializable]
	public class SitecoreDetails
	{
		public string SiteName
		{
			get
			{
				if (Sitecore.Context.Site != null)
				{
					return Sitecore.Context.Site.Name;
				}
				return "";
			}
		}
		public string CurrentItem
		{
			get
			{
				if (Sitecore.Context.Item != null)
				{
					return Sitecore.Context.Item.Paths.FullPath;
				}
				return ""; ;
			}
		}

	}
	[Serializable]
	public class WebDetails
	{
		public string Url
		{
			get
			{
				if (HttpContext.Current.Request.Url != null)
				{
					return HttpContext.Current.Request.Url.ToString();
				}
				return "";
			}
			set { }
		}
		public string Browser
		{
			get
			{
				if (HttpContext.Current.Request.Browser != null && HttpContext.Current.Request.Browser.Browser != null)
				{
					return HttpContext.Current.Request.Browser.Browser.ToString();
				}
				return "";
			}
			set { }
		}
		public string UrlReferrer
		{
			get
			{
				if (HttpContext.Current.Request.UrlReferrer != null)
				{
					return HttpContext.Current.Request.UrlReferrer.ToString();
				}
				return "";
			}
			set { }
		}
		public string UserAgent
		{
			get
			{
				if (HttpContext.Current.Request.UserAgent != null)
				{
					return HttpContext.Current.Request.UserAgent.ToString();
				}
				return "";
			}
			set { }
		}
		public string UserHostAddress
		{
			get
			{
				if (HttpContext.Current.Request.UserHostAddress != null)
				{
					return HttpContext.Current.Request.UserHostAddress.ToString();
				}
				return "";
			}
			set { }
		}
		public string UserHostName
		{
			get
			{
				if (HttpContext.Current.Request.UserHostName != null)
				{
					return HttpContext.Current.Request.UserHostName.ToString();
				}
				return "";
			}
			set { }
		}
		public ObjectData[] SessionData
		{
			get
			{
				List<ObjectData> data = new List<ObjectData>();
				if (HttpContext.Current.Session != null)
				{
					for (var i = 0; i < HttpContext.Current.Session.Count; i++)
					{
						try
						{
							var session = HttpContext.Current.Session[i];
							var sessionkey = HttpContext.Current.Session.Keys[i];

							var extracted = Logger.GetObjectData(session);
							data.Add(extracted);
						}
						catch
						{

						}
					}
				}

				return data.ToArray();
			}
			set { }
		}

	}
	[Serializable]
	public class ObjectData
	{
		[ScriptIgnoreAttribute]
		public int Level { get; set; }
		[ScriptIgnoreAttribute]
		public string Visibility { get; set; }
		[ScriptIgnoreAttribute]
		public string Type { get; set; }
		public string Name { get; set; }
		public string Value { get; set; }
		public List<ObjectData> Data { get; set; }
	}

}
