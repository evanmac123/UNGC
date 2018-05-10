module Api
  module V1
    class MitShiftController < ApiController
      protect_from_forgery with: :null_session

      before_action :authorize_mit!

      def step1
        resource = Resource.find_by(id: resource_id)
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
        uri = URI.parse(shift_params.fetch(:resource_url))
        uri&.path&.gsub("/library/", "")&.to_i
      end

    end
  end
end
