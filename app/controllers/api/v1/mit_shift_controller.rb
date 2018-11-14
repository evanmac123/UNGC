module Api
  module V1
    class MitShiftController < ApiController
      protect_from_forgery with: :null_session

      before_action :authorize_mit!

      def step1
        resource = resource_by_uri
        if resource.present?
          render json: { resource_id: resource.id }
        else
          render json: {}
        end
      end

      def step3
        attrs = weight_params
        id = attrs.delete(:resource_id)

        ResourceWeight \
          .create_with(attrs)
          .find_or_create_by!(resource_id: id)

        render nothing: true
      end

      private

      def authorize_mit!
        if auth_token != mit_shift_api_key
          render status: 401, json: {
            error: "Invalid auth token: #{auth_token}"
          }
        end
      end

      def auth_token
         request.env["HTTP_AUTHORIZATION"]
      end

      def mit_shift_api_key
        token = DEFAULTS[:mit_shift]["api_key"]
        "Bearer #{token}"
      end

      def shift_params
        params.require(:mit_shift).permit(:resource_url)
      end

      def weight_params
        input = params.require(:mit_shift).permit!

        {
          full_text: input.delete("full_text_words"),
          full_text_raw: input.delete("full_text_all"),
          resource_id: input.delete("resource_id"),
          resource_type: input.delete("resource_type"),
          resource_url: input.delete("resource_url"),
          resource_title: input.delete("resource_title"),
          weights: input
        }
      end

      def resource_id
        uri = URI.parse(requested_uri)
        uri&.path&.gsub("/library/", "")&.to_i
      end

      def requested_uri
        shift_params.fetch(:resource_url)
      end

      def resource_by_uri
        # returns the resource from either it's url or one of its links
        # Need to search both protocols since Rails will force secure protocol but stored URL may be http:
        link_protocols = *requested_uri
        link_protocols << "http#{requested_uri[5, requested_uri.length]}" if requested_uri[0, 5] == 'https'
        resource_link = ResourceLink.joins(:resource).find_by(url: link_protocols)
        resource_link&.resource || Resource.find_by(id: resource_id)
      end
    end
  end
end
