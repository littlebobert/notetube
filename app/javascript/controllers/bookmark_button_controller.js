import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="bookmark-button"
export default class extends Controller {
  static targets = ["form", "button", "icon", "tagContainer"]
  static values = {
    bookmarked: Boolean
  }

  connect() {
    console.log("Bookmark controller connected");
    this.tooltip = new bootstrap.Tooltip(this.buttonTarget);
  }
  
  showTagFormIfNeeded() {
    const bookmarkIcon = this.iconTarget;
    if (bookmarkIcon.classList.contains("fa-solid")) {
      this.tagContainerTarget.classList.remove("d-none");
    } else {
      this.tagContainerTarget.classList.add("d-none");
    }
  }

  // Define an action to handle form submission
  handleSubmit(event) {
    event.preventDefault() // Prevent the default form submission
    const form = this.formTarget;
    const url = form.action    // assign the action URL of the form (where the form will be submitted to), to url

    fetch(url, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").getAttribute("content"),
        "Accept": "text/vnd.turbo-stream.html"   // indicates that we expect the server to respond with a Turbo stream response, which allow is to update parts of the page
      },
      body: new FormData(form)
    })
    .then(response => response.text())
    .then(html => {
      this.tooltip.hide();
      if (this.iconTarget.classList.contains("fa-solid")) {
        this.iconTarget.classList.remove("fa-solid");
        this.iconTarget.classList.add("fa-regular");
        this.buttonTarget.title = "Save";
      } else {
        this.iconTarget.classList.remove("fa-regular");
        this.iconTarget.classList.add("fa-solid");
        this.buttonTarget.title = "Remove from saved";
      }
      if (this.tooltip) {
        this.tooltip = new bootstrap.Tooltip(this.buttonTarget);
        this.tooltip.show();
      }
      this.showTagFormIfNeeded();
    })
    .catch(error => {
      console.error('Error:', error)
    });
  }
}
