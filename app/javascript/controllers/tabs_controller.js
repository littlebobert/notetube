import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tabs"
export default class extends Controller {
  static targets = ["content", "tab"];

  connect() {
    this.loadContent(this.currentUrl());
  }

  switchTab(event) {
    event.preventDefault();
    const url = event.currentTarget.href;
    this.loadContent(url);
    this.updateActiveTab(event.currentTarget);
  }

  loadContent(url) {
    fetch(url, {
      headers: {
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => response.text())
    .then(html => {
      const parser = new DOMParser();
      const doc = parser.parseFromString(html, 'text/html');
      const newContent = doc.getElementById('notes-or-transcript').innerHTML;
      this.contentTarget.innerHTML = newContent;
    });
  }

  updateActiveTab(activeTab) {
    this.tabTargets.forEach(tab => tab.classList.remove('active'));
    activeTab.classList.add('active');
  }

  currentUrl() {
    return window.location.href;
  }
}
