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
      name = controller.to_s.dasherize
      stimulus_controller = get_controller(name)

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
      controller = binding.local_variable_get(:for)
      name = controller.to_s.dasherize
      stimulus_controller = get_controller(name)

      action = actions.map do |event, function|
        "#{event}->#{stimulus_controller}##{function.to_s.camelize(:lower)}"
      end.join(" ").presence

      params.transform_keys! do |key|
        :"#{controller}_#{key}_param"
      end

      defaults = { **params, **data }

      if action
        defaults[:action] = action
      end

      if target
        defaults[:"#{controller}_target"] = target.to_s.camelize(:lower)
      end

      defaults
    end

    def get_controller(controller)
      controllers = site.data['controllers'].to_h { [it["name"], it] }
      controllers.fetch(controller)["name"]
    rescue KeyError => exception
      raise "Unkown stimulus controller #{controller}. Did you mean #{exception.corrections.join(', ')}"
    end
  end
end
