module Api
  module V1
    class BaseController < ApplicationController
      include Authenticatable
      include Pagy::Backend

      skip_before_action :verify_authenticity_token

      protected

      def pagy_metadata(pagy)
        {
          current_page: pagy.page,
          total_pages: pagy.pages,
          total_count: pagy.count,
          per_page: pagy.vars[:items] || pagy.limit,
          has_next_page: pagy.next.present?,
          has_prev_page: pagy.prev.present?
        }
      end

      def paginated_response(collection, pagy, serializer: nil, **options)
        serialized_data = if serializer
          ActiveModelSerializers::SerializableResource.new(
            collection,
            each_serializer: serializer,
            **options
          )
        else
          collection
        end

        json_response({
          data: serialized_data,
          pagination: pagy_metadata(pagy)
        })
      end
    end
  end
end
