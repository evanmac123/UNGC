package org.unglobalcompact.search;

import org.apache.poi.xwpf.extractor.XWPFWordExtractor;
import org.apache.poi.xwpf.usermodel.XWPFDocument;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

public class DocxReader {

  public static void main(String[] args) throws Exception {
    if (args.length < 1) {
      System.out.println("Usage: java org.unglobalcompact.search.WordXmlReader <file>");
      return;
    }

    FileInputStream fin = new FileInputStream(args[0]);
    XWPFDocument doc = new XWPFDocument(fin);
    XWPFWordExtractor e = new XWPFWordExtractor(doc);
    System.out.println(e.getText());
    fin.close();
  }
}
