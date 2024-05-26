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
    this.playerOrIframeTarget.innerHTML = `<div id="player"></div>`;
    // This code loads the YouTube IFrame Player API code asynchronously.
    var tag = document.createElement('script');
    tag.src = "https://www.youtube.com/iframe_api";
    var firstScriptTag = this.element.ownerDocument.getElementsByTagName('script')[0];
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
    console.log(this.transcriptTabTarget);
    console.log(this.playerOrIframeTarget);
    this.notesTabTarget.classList.remove("active");
    this.transcriptTabTarget.classList.add("active");
    console.log(this.contentTarget);
    console.log(this.noteIdValue);
    var url = `/notes/${this.noteIdValue}/beautiful_transcript`
    fetch(url)
      .then(response => response.text())
      .then((response) => {
        var json = JSON.parse(response);
        console.log(json);
        var paragraphs = json["paragraphs"]
        console.log(paragraphs);
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
