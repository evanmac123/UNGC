import org.apache.poi.hslf.extractor.PowerPointExtractor;
import java.io.*;

public class PptReader {

  public static void main(String[] args) throws Exception {
    FileInputStream fin = new FileInputStream(args[0]);
    PowerPointExtractor e = new PowerPointExtractor(fin);
    System.out.println(e.getText());
  }
}

