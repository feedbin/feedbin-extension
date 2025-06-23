import { Controller } from "../lib/stimulus.js";
import { sharedStore } from "../store.js";

export default class extends Controller {
  static targets = [
    "submitButton",
    "error",
    "feedTemplate",
    "feedResults",
    "tagTemplate",
    "tagResults",
  ];
  static values = {
    loading: Boolean,
    url: String,
    hasResults: Boolean,
  };

  async submit(event) {
    console.log(event);

    this.submitButtonTarget.disabled = true;
    this.loadingValue = true;
    this.errorTarget.textContent = "";

    const user = sharedStore.getUser();
    const pageInfo = sharedStore.getPageInfo();

    const formData = new FormData(this.element);
    formData.append("page_token", user.page_token);
    formData.append("url", pageInfo.url);

    try {
      // const response = await fetch(this.element.action, {
      //   method: this.element.method || "POST",
      //   body: new URLSearchParams(formData),
      // });
      //
      // if (!response.ok) {
      //   const error = new Error(`Invalid response`);
      //   error.response = response;
      //   throw error;
      // }

      // const data = await response.json();
      const data = {
        feeds: [
          {
            url: "https://daringfireball.net/feeds",
            title: "Daring Fireball",
            display_url: "daringfireball.net › index.xml",
            volume: "16h ago, 98/mo"
          },
          {
            url: "https://daringfireball.net/feeds/json",
            title: "Daring Fireball",
            display_url: "daringfireball.net › feed.json",
            volume: "16h ago, 98/mo"
          }
        ],
        tags: ["Favorites", "Feeds", "Social"]
      }

      this.dispatch("resultsLoaded", { detail: data });
      this.hasResultsValue = true;
    } catch (error) {
      if ("response" in error) {
        this.errorTarget.textContent = `Invalid response: ${error.response.statusText}`;
      } else {
        this.errorTarget.textContent = `Unknown error. ${error}`;
      }
      console.log(error);
    }

    this.submitButtonTarget.disabled = false;
    this.loadingValue = false;
  }
}
