# frozen_string_literal: true

module Crm
  module Adapters
    class Donation < Crm::Adapters::Base

      def to_crm_params(transform_action)
        # NB we need to parse the raw stripe response
        # so that we can serialize it all back down as a single
        # JSON field.
        {
            IdField: model.id,
            MetadataField: {
                ungc: model.metadata,
                stripe_response: JSON.parse(model.full_response),
            }.to_json
        }
      end

    end
  end
end
