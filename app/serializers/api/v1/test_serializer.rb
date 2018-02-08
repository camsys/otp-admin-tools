module Api
  module V1

    class TestSerializer < ActiveModel::Serializer

      attributes :id, :percent_matched

      def percent_matched
        object.get_percent_matched.to_f*100
      end

    end
  end
end
