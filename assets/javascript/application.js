---
---
import { Application } from "./lib/stimulus.js"
import AppController from "./controllers/app_controller.js"
import AuthenticationController from "./controllers/authentication_controller.js"
import FaviconController from "./controllers/favicon_controller.js"
import SettingsController from "./controllers/settings_controller.js"
import TabsController from "./controllers/tabs_controller.js"
import AddController from "./controllers/add_controller.js"
import SaveController from "./controllers/save_controller.js"
import PageInfoController from "./controllers/page_info_controller.js"
import SubscribeController from "./controllers/subscribe_controller.js"

const application = Application.start()
application.debug = {% if jekyll.environment == "production" %} false {% else %} true {% endif %}

application.register("app", AppController)
application.register("authentication", AuthenticationController)
application.register("favicon", FaviconController)
application.register("settings", SettingsController)
application.register("tabs", TabsController)
application.register("add", AddController)
application.register("save", SaveController)
application.register("page-info", PageInfoController)
application.register("subscribe", SubscribeController)

window.Stimulus = application
