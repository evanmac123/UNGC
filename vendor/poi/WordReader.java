import org.apache.poi.hwpf.extractor.WordExtractor;
import java.io.*;

public class WordReader {

  public static void main(String[] args) throws Exception {
    FileInputStream fin = new FileInputStream(args[0]);
    WordExtractor e = new WordExtractor(fin);
    System.out.println(e.getText());
  }
}

