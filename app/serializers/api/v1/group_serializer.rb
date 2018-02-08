module Api
  module V1

    class GroupSerializer < ActiveModel::Serializer

      attributes :id, :name, :comment, :compare_type, :latest_test

      def latest_test
        if object.tests.count == 0
          return nil
        else
          Api::V1::TestSerializer.new(@object.tests.last)
        end
      end

    end
  end
end
