module Views
  module Shared
    class MessageIcon < Jekyll::Component
      def initialize(type: nil, icon: nil)
        @type = type
        @icon = icon
      end

      def view_template
        div class: "w-[32px] h-[32px] flex items-center justify-center relative" do
          render Icon.new(icon: icon_name, css_class: icon_class)

          div class: "z-1 shrink-0 w-[32px] h-[32px] rounded-full absolute #{bg_class}"

          if @type == "success" || @type == "error"
            div class: "z-0 shrink-0 w-[32px] h-[32px] rounded-full absolute animate-grow-fade #{animate_bg_class}"
          end
        end
      end

      private

      def icon_name
        case @type
        when "success"
          "check"
        when "error"
          "exclamation"
        else
          @icon
        end
      end

      def fill_class
        if @type == "success" || @type == "error"
          "fill-white"
        else
          "fill-700"
        end
      end

      def icon_class
        "z-2 shrink-0 absolute #{fill_class}"
      end

      def bg_class
        case @type
        when "success"
          "bg-green-600"
        when "error"
          "bg-red-600"
        else
          "bg-200"
        end
      end

      def animate_bg_class
        @type == "success" ? "bg-green-600/20" : "bg-red-600/20"
      end
    end
  end
end
