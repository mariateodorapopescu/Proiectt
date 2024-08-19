package bean;
import java.util.Timer;
// importare biblioteci
/**
 * Clasa scheduler mail-uri
 */
	public class DBScheduler
	{
		/**
		 * functia ce porneste un timer
		 * @throws Exception
		 */
		public void pornire() throws Exception
		{
			System.out.println("Pornire...");
			// ReadPropertiesFile.readConfig();
			Timer timer = new Timer();
			timer.scheduleAtFixedRate(new Testing(), getTimePrecision("2s"), getTimePrecision("1d"));
		}
		/**
		 * Transformare din timp si unitoate doar in timp pentru a i se da valorea timerului
		 * @param value
		 * @return numarul de milisecunde pentru a repeta actiunea
		 * @throws Exception
		 */
		public long getTimePrecision(String value) throws Exception
		{
			// declarare si initialiaare variabișe
			long  l = 0;
			String val="";
			try
			{
				if(value.endsWith("d") || value.endsWith("D"))
				{
					val  = value.substring(0,value.length()-1); // se ia pana la ultima litera, care este unitatea
					l = Long.parseLong(val) * 24 * 60 * 60 * 1000; // se afla milisecundele
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
				// aici nu mai stiu ce am vrut sa fac ;_;
	            throw new Exception(e);
			}
			return l;
		}
		public static void main(String a[]) throws Exception
		{
			// initializez un obiect din acesta si setez timerul/il pornesc
			DBScheduler dbs = new DBScheduler();
			dbs.pornire();
		}

	}