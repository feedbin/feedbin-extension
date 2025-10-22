---
---
import { Application } from "./lib/stimulus.js"
const application = Application.start()
application.debug = {% if jekyll.environment == "production" %} false {% else %} true {% endif %}

{% for controller in site.data.controllers -%}
import {{ controller.class_name }} from "{{ controller.path }}"
application.register("{{ controller.name }}", {{ controller.class_name }})
{% endfor %}

window.Stimulus = application
