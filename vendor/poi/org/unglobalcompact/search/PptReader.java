package org.unglobalcompact.search;

import org.apache.poi.hslf.extractor.PowerPointExtractor;
import java.io.*;

public class PptReader {

  public static void main(String[] args) throws Exception {
	if (args.length != 1) {
	  System.out.println("Usage: java org.unglobalcompact.search.PptReader <file>");
	  return;
	}
    FileInputStream fin = new FileInputStream(args[0]);
    PowerPointExtractor e = new PowerPointExtractor(fin);
    System.out.println(e.getText());
  }
}

