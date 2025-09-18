import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["cardsButton", "tableButton", "cardsView", "tableView"]

  connect() {
    const savedView = localStorage.getItem('vehicleView') || 'cards'
    if (savedView === 'table') {
      this.showTable()
    } else {
      this.showCards()
    }
  }

  showCards() {
    if (this.hasCardsButtonTarget) {
      this.cardsButtonTarget.classList.add('is-selected')
    }
    if (this.hasTableButtonTarget) {
      this.tableButtonTarget.classList.remove('is-selected')
    }

    if (this.hasCardsViewTarget) {
      this.cardsViewTarget.classList.remove('is-hidden')
    }
    if (this.hasTableViewTarget) {
      this.tableViewTarget.classList.add('is-hidden')
    }

    localStorage.setItem('vehicleView', 'cards')
  }

  showTable() {
    if (this.hasTableButtonTarget) {
      this.tableButtonTarget.classList.add('is-selected')
    }
    if (this.hasCardsButtonTarget) {
      this.cardsButtonTarget.classList.remove('is-selected')
    }

    if (this.hasTableViewTarget) {
      this.tableViewTarget.classList.remove('is-hidden')
    }
    if (this.hasCardsViewTarget) {
      this.cardsViewTarget.classList.add('is-hidden')
    }

    localStorage.setItem('vehicleView', 'table')
  }
}