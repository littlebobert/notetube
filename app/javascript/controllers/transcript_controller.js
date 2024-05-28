import { Controller } from "@hotwired/stimulus"


// Connects to data-controller="transcript"
export default class extends Controller {
  static targets = ["content", "transcriptTab", "notesTab", "playerOrIframe", "edit"];
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
        MathJax.typeset();
      })
  }
  
  connect() {
    this.loadNotesAsync();
  }
  
  edit(event) {
    this.editTarget.innerHTML = `<strong class="btn-icon" data-controller="tooltip" data-bs-toggle="tooltip" data-bs-position="bottom" title="Save"><i class="fa-solid fa-floppy-disk"></i></strong>`
    this.editTarget.dataset.action = "click->transcript#save"
    this.contentTarget.contentEditable = "true";
  }
  
  save(event) {
    var url = `/notes/${this.noteIdValue}`
    var formData = new FormData(); 
    formData.append("note", JSON.stringify({ "memo_html": this.contentTarget.innerHTML }));

    fetch(url, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").getAttribute("content"),
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: JSON.stringify({
        note: {
          memo_html: this.contentTarget.innerHTML
        }
      })
    })
      .then(response => response.json())
      .then(html => {
        console.log("successful save");
      })
      .catch(error => console.error('Error:', error))
    
    this.editTarget.innerHTML = `<strong class="btn-icon" data-controller="tooltip" data-bs-toggle="tooltip" data-bs-position="bottom" title="Edit"><i class="fa-solid fa-pen-to-square"></i></strong>`
    this.editTarget.dataset.action = "click->transcript#edit"
    this.contentTarget.contentEditable = "false";
  }
  
  switchToNotes(event) {
    event.preventDefault();
    this.loadNotesAsync();
  }
  
  fetchRawTranscript(event) {
    event.preventDefault();
    
    this.notesTabTarget.classList.remove("active");
    this.transcriptTabTarget.classList.add("active");
    this.contentTarget.innerHTML = "Loading…"
  
    var url = `/notes/${this.noteIdValue}/raw_transcript`
    fetch(url)
      .then(response => response.text())
      .then((response) => {
        var json = JSON.parse(response);
        var html = "";
        var number_of_captions = 0;
        Array.from(json).forEach((blob) => {
          var paragraph = blob["caption"];
          var start_time = blob["start_time"];
          var duration = blob["duration"];
          html += `<span class="caption" onclick="jumpTo(${start_time})" data-start-time="${start_time}" data-duration="${duration}">${paragraph}</span> `
          number_of_captions += 1;
          if (number_of_captions % 5 == 0) {
            html += "<br><br>";
          }
        });
        this.contentTarget.innerHTML = html;
      })
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
