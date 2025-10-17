module Views
  module Shared
    class Checkbox < Jekyll::Component
      def initialize(**attributes)
        @attributes = attributes
      end

      def view_template
        input(
          type: "checkbox",
          class: "active:bg-200 flex h-[16px] w-[16px] appearance-none shrink-0 items-center justify-center rounded border border-input shadow-sm outline-2 outline-offset-1 outline-transparent transition before:block before:h-[7px] before:w-[9px] before:bg-transparent before:content-[''] checked:border-blue-600 checked:bg-blue-600 checked:before:bg-white focus-visible:shadow-none focus-visible:outline-blue-400 active:checked:border-blue-700 active:checked:bg-blue-700",
          **@attributes
        )
      end
    end
  end
end
