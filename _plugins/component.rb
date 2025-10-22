require "phlex"
require "uri"
require "nokogiri"
require "ostruct"
require "active_support/inflector"
require "active_support/core_ext/object/blank"

module Views
  module Shared
    extend Phlex::Kit
  end
end

module Jekyll
  class Component < Phlex::HTML
    include ::Views::Shared

    def site
      Jekyll.sites.first
    end

    def build_url(url_key)
      host = site.config.dig("api_host", Jekyll.env)
      path = site.config.dig("urls", url_key)
      URI.join(host, path).to_s
    end

    def stimulus(controller:, actions: {}, values: {}, outlets: {}, classes: {}, data: {})
      stimulus_controller = controller.to_s.dasherize

      action = actions.map do |event, function|
        "#{event}->#{stimulus_controller}##{function.to_s.camelize(:lower)}"
      end.join(" ").presence

      values.transform_keys! do |key|
        [controller, key, "value"].join("_").to_sym
      end

      outlets.transform_keys! do |key|
        [controller, key, "outlet"].join("_").to_sym
      end

      classes.transform_keys! do |key|
        [controller, key, "class"].join("_").to_sym
      end

      { controller: stimulus_controller, action: }.merge!({ **values, **outlets, **classes, **data})
    end

    def stimulus_item(target: nil, actions: {}, params: {}, data: {}, for:)
      stimulus_controller = binding.local_variable_get(:for).to_s.dasherize

      action = actions.map do |event, function|
        "#{event}->#{stimulus_controller}##{function.to_s.camelize(:lower)}"
      end.join(" ").presence

      params.transform_keys! do |key|
        :"#{binding.local_variable_get(:for)}_#{key}_param"
      end

      defaults = { **params, **data }

      if action
        defaults[:action] = action
      end

      if target
        defaults[:"#{binding.local_variable_get(:for)}_target"] = target.to_s.camelize(:lower)
      end

      defaults
    end
  end
end
