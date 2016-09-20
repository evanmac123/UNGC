Paperclip.options[:content_type_mappings] = {
  # Many browser/OS combinations fail to report their content-types properly
  # Allow .pdf files to match when they present with the following content-types
  pdf: %w(binary/octet-stream text/pdf application/pdf)
}
