import { Controller } from "@hotwired/stimulus"


// Connects to data-controller="transcript"
export default class extends Controller {
  static targets = ["content", "transcriptTab", "notesTab", "playerOrIframe"];
  static values = {
    noteId: String
  }
  
  loadNotesAsync() {
    this.transcriptTabTarget.classList.remove("active");
    this.notesTabTarget.classList.add("active");
    this.contentTarget.innerHTML = "Loading…"
    
    var url = `/notes/${this.noteIdValue}/raw_notes`
    fetch(url)
      .then(response => response.text())
      .then((response) => {
        this.contentTarget.innerHTML = response;
      })
  }
  
  connect() {
    this.loadNotesAsync();
  }
  
  switchToNotes(event) {
    event.preventDefault();
    this.loadNotesAsync();
  }
  
  fetch(event) {
    event.preventDefault();
    
    this.notesTabTarget.classList.remove("active");
    this.transcriptTabTarget.classList.add("active");
    this.contentTarget.innerHTML = "Loading…"

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
          html += `<div class="caption mb-3" onclick="jumpTo(${start_time})" data-start-time="${start_time}" data-duration="${duration}">${paragraph}</div>`
        });
        this.contentTarget.innerHTML = html;
      })
  }
}
