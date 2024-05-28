import { Controller } from "@hotwired/stimulus"
import { tips } from "../tips";

// Connects to data-controller="transcript"
export default class extends Controller {
  static targets = ["content", "transcriptTab", "notesTab", "playerOrIframe", "edit"];
  static values = {
    noteId: String
  }

  showLoadingAnimation() {
    const loadingHTML = `
      <div id="loading-container" style="text-align: center;">
        <div id="loading-animation" style="
          width: 50px;
          height: 50px;
          border: 5px solid #ccc;
          border-top: 5px solid #1d72b8;
          border-radius: 50%;
          animation: spin 1s linear infinite;
          margin: 0 auto;
        "></div>
        <div id="loading-text" style="
          margin-top: 10px;
          font-size: 20px;
          font-weight: bold;
        ">Loading…</div>
        <div id="loading-tip" style="
          margin-top: 20px;
          font-size: 16px;
          color: #666;
          text-align: left;
          padding: 0 20px;
        ">Fetching notes, please wait...</div>
      </div>
    `;

    this.contentTarget.innerHTML = loadingHTML;

    let tipIndex = 0;

    const loadingTip = this.contentTarget.querySelector("#loading-tip");

    function showNextTip() {
      const randomTip = tips[Math.floor(Math.random() * tips.length)];
      loadingTip.innerText = randomTip;
    }

    setInterval(showNextTip, 5000); // Change tip every 3 seconds
    showNextTip();
  }
  
  decodeHTML(html) {
    var txt = document.createElement("textarea");
    txt.innerHTML = html;
    return txt.value;
  }

  loadNotesAsync() {
    this.transcriptTabTarget.classList.remove("active");
    this.notesTabTarget.classList.add("active");
    this.showLoadingAnimation();

    var url = `/notes/${this.noteIdValue}/raw_notes`
    fetch(url)
      .then(response => response.text())
      .then((response) => {
        this.contentTarget.innerHTML = this.decodeHTML(response);
        MathJax.typeset();
      })
  }

  connect() {
    this.loadNotesAsync();
    if (!document.getElementById('loading-animation-styles')) {
      const styleSheet = document.createElement("style");
      styleSheet.type = "text/css";
      styleSheet.id = 'loading-animation-styles';
      styleSheet.innerText = `
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
      `;
      document.head.appendChild(styleSheet);
    }
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
    this.showLoadingAnimation();

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
