package org.unglobalcompact.search;

import org.apache.poi.hwpf.extractor.WordExtractor;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

public class WordReader {

  public static void main(String[] args) throws Exception {
    if (args.length < 1) {
      System.out.println("Usage: java org.unglobalcompact.search.WordReader <file>");
      return;
    }

    FileInputStream fin = new FileInputStream(args[0]);
    WordExtractor e = new WordExtractor(fin);
    System.out.println(e.getText());
    fin.close();
  }
}
