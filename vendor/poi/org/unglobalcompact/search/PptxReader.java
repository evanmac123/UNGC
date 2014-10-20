package org.unglobalcompact.search;

import org.apache.poi.xslf.extractor.XSLFPowerPointExtractor;
import org.apache.poi.xslf.usermodel.XMLSlideShow;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

public class PptxReader {

  public static void main(String[] args) throws Exception {
    if (args.length < 1) {
      System.out.println("Usage: java org.unglobalcompact.search.PptxReader <file>");
      return;
    }

    FileInputStream fileStream = new FileInputStream(args[0]);
    try {
      XMLSlideShow slideShow = new XMLSlideShow(fileStream);
      XSLFPowerPointExtractor extractor = new XSLFPowerPointExtractor(slideShow);
      System.out.println(extractor.getText());
    } finally {
      fileStream.close();
    }
  }
}
