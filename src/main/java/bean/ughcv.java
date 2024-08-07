package bean;
import java.awt.AWTException;
import java.awt.Robot;
import java.awt.Toolkit;
import java.awt.datatransfer.Clipboard;
import java.awt.datatransfer.StringSelection;
import java.awt.event.KeyEvent;
import java.util.Scanner;
public class ughcv {
	public static void main(String[] args) throws AWTException, InterruptedException {
		Scanner scanner = new Scanner(System.in);
		System.out.println("Enter the msg");
		String msg = scanner.nextLine();
		System.out.println(msg);
		System.out.println("How many times do you want the message to be send?");
		int size = scanner.nextInt();
		StringSelection ceva = new StringSelection(msg);
		Clipboard clipboard = Toolkit.getDefaultToolkit().getSystemClipboard();
		clipboard.setContents(ceva, null);
		Thread.sleep(3000);
		Robot robot = new Robot();
		for (int i = 0; i < size; i++) {
			
			robot.keyPress(KeyEvent.VK_CONTROL);
			robot.keyPress(KeyEvent.VK_V);
			robot.keyRelease(KeyEvent.VK_CONTROL);
			robot.keyRelease(KeyEvent.VK_V);
		}
	}
}
