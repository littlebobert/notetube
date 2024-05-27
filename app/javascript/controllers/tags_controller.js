import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tags"
export default class extends Controller {
  static targets = ["tagContainer"]
  connect() {
    console.log("tags connected");
  }

  create(e) {
    const bookmarkIcon = e.currentTarget.querySelector("i");
    if (bookmarkIcon.classList.contain("fa-solid")) {
      this.targetTagContainer.classList.remove("d-none");
    }
    else
    {
      this.targetTagContainer.classList.add("d-none");
    }
  }

}
