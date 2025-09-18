import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["typeFilter", "dateFrom", "dateTo"]

  connect() {
    this.filter()
  }

  filterByType() {
    this.filter()
  }

  filterByDate() {
    this.filter()
  }

  filter() {
    const typeFilter = this.hasTypeFilterTarget ? this.typeFilterTarget.value : ''
    const dateFrom = this.hasDateFromTarget ? this.dateFromTarget.value : ''
    const dateTo = this.hasDateToTarget ? this.dateToTarget.value : ''

    const serviceRows = this.element.querySelectorAll('[data-service-type]')

    serviceRows.forEach(row => {
      const serviceType = row.dataset.serviceType || ''
      const serviceDate = row.dataset.serviceDate || ''

      const matchesType = !typeFilter || serviceType === typeFilter
      const matchesDateFrom = !dateFrom || serviceDate >= dateFrom
      const matchesDateTo = !dateTo || serviceDate <= dateTo

      const shouldShow = matchesType && matchesDateFrom && matchesDateTo

      if (shouldShow) {
        row.style.display = ''
      } else {
        row.style.display = 'none'
      }
    })
  }
}