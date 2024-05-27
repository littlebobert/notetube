import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tags"
export default class extends Controller {
  static targets = ["tagContainer"]
  connect() {
    console.log("tags connected");
  }

  create(e) {
    const bookmarkIcon = e.currentTarget.querySelector("i");
    if (bookmarkIcon.classList.contains("fa-solid")) {
      this.tagContainerTarget.classList.add("d-none");
    }
    else
    {
      this.tagContainerTarget.classList.remove("d-none");
    }
  }

}
