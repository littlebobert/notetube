import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="bookmark-button"
export default class extends Controller {

  connect() {
    console.log("Bookmark controller connected")
  }

  // Define an action to handle form submission
  handleSubmit(event) {
    event.preventDefault() // Prevent the default form submission
    const form = event.currentTarget  //assgin the form element to the variable form
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
      document.querySelector("#bookmark-button").innerHTML = html
    })
    .catch(error => console.error('Error:', error))
  }
}
