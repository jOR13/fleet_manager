import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]

  connect() {
    console.log("Report filter controller connected")
  }

  applyFilters() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.submitForm()
    }, 500)
  }

  submitForm() {
    const form = this.element.querySelector('form')
    if (form) {
      form.requestSubmit()
    }
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }
}