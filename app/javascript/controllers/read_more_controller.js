import ReadMore from '@stimulus-components/read-more'

export default class extends ReadMore {
  connect() {
    super.connect()
    console.log('Do what you want here.')
  }

  // Function to override on toggle.
  toggle(event) {
    console.log("toggle");
    super.toggle();
  }

  // Function to override when the text is shown.
  show(event) {
    console.log("show");
  }

  // Function to override when the text is hidden.
  hide(event) {
    console.log("hide");
  }
}
