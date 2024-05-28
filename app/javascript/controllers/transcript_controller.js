import { Controller } from "@hotwired/stimulus"


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
    this.showLoadingAnimation();

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


const tips = [
  "Why do programmers prefer dark mode? Because the light attracts bugs!",
  "To understand recursion, you must first understand recursion.",
  "Debugging: Being the detective in a crime movie where you are also the murderer.",
  "There are 10 types of people in the world: those who understand binary, and those who don't.",
  "I would love to change the world, but they won’t give me the source code.",
  "Programming is like writing a book... except if you miss a single comma on page 126 the whole thing makes no sense.",
  "In order to understand recursion, one must first understand recursion.",
  "Real programmers count from 0.",
  "A SQL query walks into a bar, walks up to two tables and asks: 'Can I join you?'",
  "Why do Java developers wear glasses? Because they can't C#.",
  "How many programmers does it take to change a light bulb? None, that's a hardware problem.",
  "A programmer's wife tells him: 'While you're at the store, get some milk.' He never comes back.",
  "Why do programmers always mix up Christmas and Halloween? Because Oct 31 == Dec 25.",
  "Knock, knock. Who’s there? Broken recursion. Broken recu... Knock, knock.",
  "What's a programmer's favorite place to hang out? Foo Bar.",
  "Why was the JavaScript developer sad? Because he didn't know how to 'null' his feelings.",
  "Why was the developer unhappy at their job? They wanted arrays.",
  "Algorithm: A word used by programmers when they don't want to explain what they did.",
  "How do you comfort a JavaScript bug? You console it.",
  "Why do Python programmers have low self-esteem? Because they're constantly comparing their self to others.",
  "What is the most used language in programming? Profanity.",
  "Why did the functions stop calling each other? Because they had constant arguments.",
  "What's the object-oriented way to become wealthy? Inheritance.",
  "Why don’t programmers like nature? It has too many bugs.",
  "What’s a computer’s favorite beat? An algo-rhythm.",
  "I would tell you a joke about UDP, but you might not get it.",
  "A byte walks into a bar and orders a pint. Bartender asks, 'What's wrong?' Byte says, 'Parity error.' Bartender nods and says, 'Yeah, I thought you looked a bit off.'",
  "What’s the best way to catch a runaway computer? Use the Inter-net.",
  "Why do programmers prefer iOS development? Because it doesn’t allow garbage collection.",
  "Why don't bachelors like Git? Because they are afraid to commit."
];
