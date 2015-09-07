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

class ThinkingSphinx::Middlewares::SphinxQL

  # this added rand_seed to thinking_sphinx supported options
  # should be removed once thinking_sphinx adds native support for it
  SELECT_OPTIONS = [:agent_query_timeout, :boolean_simplify, :comment, :cutoff,
    :field_weights, :global_idf, :idf, :index_weights, :max_matches,
    :max_query_time, :max_predicted_time, :ranker, :retry_count, :retry_delay,
    :reverse_scan, :sort_method, :rand_seed]

  end
