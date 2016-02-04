# encoding: UTF-8
require 'test_helper'
require './lib/file_text_extractor'

class FileTextExtractorTest < ActiveSupport::TestCase

  should "extract text from ppt files" do
    assert_extracts \
      path: '../../vendor/poi/sample.ppt',
      pattern: /Nonlinear estimation of an information-processing model./
  end

  should "extract text from pptx files" do
    assert_extracts \
      path: '../../vendor/poi/sample.pptx',
      pattern: /Range from 100-400 watts in use, 1-20 watts standby/
  end

  should "extract text from docx files" do
    assert_extracts \
      path: '../../vendor/poi/sample.docx',
      pattern: /example of a word document/
  end

  should "extract text from doc files" do
    assert_extracts \
      path: '../../vendor/poi/sample2.doc',
      pattern: /This is a test/
  end

  should "extract text from pdf files" do
    assert_extracts \
      path: '../../vendor/poi/sample.pdf',
      pattern: /Each chapter should be included in the main document as a separate ﬁle/
  end

  private

  def assert_extracts(args)
    path = args.fetch(:path)
    pattern = args.fetch(:pattern)

    content_type = MIME::Types.type_for(path).join(',')
    attachment = fixture_file_upload(path, content_type)
    file = create_cop_file(attachment: attachment)
    contents = FileTextExtractor.extract(file)
    assert_match(pattern, contents)
  end

end
