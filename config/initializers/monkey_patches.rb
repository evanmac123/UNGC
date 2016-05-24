# TODO remove this once rails 4.2.3 (hopefully) fixes the sanitize bug
module ActionView
 module Helpers
   module SanitizeHelper
     def strip_tags(html)
       self.class.full_sanitizer.sanitize(html, encode_special_chars: false)
     end
   end
 end
end
