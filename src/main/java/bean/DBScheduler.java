package bean;
import java.util.Timer;

	public class DBScheduler
	{

		public void callScheduler() throws Exception
		{

			System.out.println("Started...");
			ReadPropertiesFile.readConfig();
			Timer timer = new Timer();

			timer.scheduleAtFixedRate(new Testing(), getTimePrecision(Constants.delay), getTimePrecision("1h"));

		}

		public long getTimePrecision(String value) throws Exception
		{
			long  l = 0;
			String val="";
			try
			{
				if(value.endsWith("d") || value.endsWith("D"))
				{
					val  = value.substring(0,value.length()-1);
					l = Long.parseLong(val) * 24 * 60 * 60 * 1000;
				}

				else if(value.endsWith("h") || value.endsWith("H"))
				{

				 val  = value.substring(0,value.length()-1);
				 l = Long.parseLong(val) * 60 * 60 * 1000;

				}
				else if(value.endsWith("m") || value.endsWith("M"))
				{
					 val  = value.substring(0,value.length()-1);
					 l = Long.parseLong(val) * 60 * 1000;
				}
				else if(value.endsWith("s") || value.endsWith("S"))
				{

					val  = value.substring(0,value.length()-1);
					l = Long.parseLong(val) * 1000;
				}
				else
				{

					l = Long.parseLong(value);
				}

			}
			catch(Exception e)
			{

	            throw new Exception(e);
			}

			return l;
		}
		public static void main(String a[]) throws Exception
		{
			DBScheduler dbs = new DBScheduler();
			dbs.callScheduler();
		}

	}