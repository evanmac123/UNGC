package org.unglobalcompact.search;

import org.apache.poi.hwpf.extractor.WordExtractor;
import org.apache.poi.xwpf.extractor.XWPFWordExtractor;
import org.apache.poi.xwpf.usermodel.XWPFDocument;

import java.io.*;

public class WordReader {

  public static void main(String[] args) throws Exception {
    if (args.length < 1) {
      System.out.println("Usage: java org.unglobalcompact.search.WordReader <file> [-x]");
      return;
    }

    FileInputStream fin = new FileInputStream(args[0]);
    System.out.println(extractText(args, fin));
    fin.close();
  }

  private static String extractText(String[] args, FileInputStream fin) throws IOException {
    if (args.length == 2 && args[1].equals("-x")) {
      return readNewFormat(fin);
    } else {
      return readOldFormat(fin);
    }
  }

  private static String readNewFormat(InputStream fin) throws IOException {
    XWPFDocument doc = new XWPFDocument(fin);
    XWPFWordExtractor e = new XWPFWordExtractor(doc);
    return e.getText();
  }

  private static String readOldFormat(InputStream fin) throws IOException {
    WordExtractor e = new WordExtractor(fin);
    return e.getText();
  }
}
