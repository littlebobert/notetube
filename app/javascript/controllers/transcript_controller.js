import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="transcript"
export default class extends Controller {
  static targets = ["content", "transcriptTab", "notesTab", "playerOrIframe"];
  static values = {
    noteId: String
  }
  connect() {
    console.log("hello world");
  }
  
  fetch(event) {
    event.preventDefault();
    // Insert the player div, the default is an iframe, which doesn’t work with the YouTube API.
    this.playerOrIframeTarget.innerHTML = `<div id="player"></div>`;
    
    // This code loads the YouTube IFrame Player API code asynchronously.
    var tag = document.createElement('script');
    tag.src = "https://www.youtube.com/iframe_api";
    var firstScriptTag = this.element.ownerDocument.getElementsByTagName('script')[0];
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
    
    this.notesTabTarget.classList.remove("active");
    this.transcriptTabTarget.classList.add("active");

    var url = `/notes/${this.noteIdValue}/beautiful_transcript`
    fetch(url)
      .then(response => response.text())
      .then((response) => {
        var json = JSON.parse(response);
        var paragraphs = json["paragraphs"]
        var html = "";
        Array.from(paragraphs).forEach((blob) => {
          var paragraph = blob["paragraph"];
          var start_time = blob["start_time"];
          var duration = blob["duration"];
          html += `<div class="caption" onclick="jumpTo(${start_time})" data-start-time="${start_time}" data-duration="${duration}">${paragraph}</div>`
        });
        this.contentTarget.innerHTML = html;
      })
  }
}
