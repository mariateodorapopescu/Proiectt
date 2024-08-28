package scheduler;

import java.io.FileInputStream;
import java.util.Properties;

public class ReadPropertiesFile
{
	public  static void readConfig() throws Exception
	{
		try
		{

		    Properties pro = new Properties();
		    String path = System.getProperty("user.dir")+"/Props.properties";
		    pro.load(new FileInputStream(path));	   

		    Constants.delay = pro.getProperty("delay");
		    Constants.timetoquery = pro.getProperty("timetoquery");
		    Constants.setFrom = pro.getProperty("setFrom");
		    Constants.setPassword = pro.getProperty("setPassword");
		    Constants.emailTO = pro.getProperty("emailTO");	  		   

		}
		catch(Exception e)
		{
            throw new Exception(e);
		}

	}

}