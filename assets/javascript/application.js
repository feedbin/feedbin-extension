---
---
import { Application } from "./lib/stimulus.js"
import TabInfoController from "./controllers/tab_info_controller.js"
import SettingsController from "./controllers/settings_controller.js"
import TabsController from "./controllers/tabs_controller.js"

const application = Application.start()
application.debug = {% if jekyll.environment == "production" %} false {% else %} true {% endif %}

application.register("tab-info", TabInfoController)
application.register("settings", SettingsController)
application.register("tabs", TabsController)

window.Stimulus = application
