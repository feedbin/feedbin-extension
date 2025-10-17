module Views
  module Shared
    class Error < Jekyll::Component
      def initialize(content: nil, **attributes)
        @content = content
        @attributes = attributes
      end

      def view_template
        div **mix({class: "mb-2 rounded border border-red-600 bg-red-200 p-3 text-red-600 empty:hidden"}, @attributes) do
          plain @content if @content
        end
      end
    end
  end
end
