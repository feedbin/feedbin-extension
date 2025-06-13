import { Application } from "./lib/stimulus.js"
import TabInfoController from "./controllers/tab_info_controller.js"

// Start the Stimulus application
const application = Application.start()

// Set debug mode for development
application.debug = false
console.log("Stimulus application started")

// Register controllers
application.register("tab-info", TabInfoController)

// Make the application globally available
window.Stimulus = application
