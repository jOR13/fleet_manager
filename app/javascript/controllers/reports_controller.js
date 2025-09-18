import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["statusChart", "typeChart"]

  connect() {
    console.log("Reports controller connected")
  }
}