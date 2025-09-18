import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["searchInput", "statusFilter", "brandFilter", "vehiclesList", "vehiclesTableBody"]

  connect() {
    this.filter()
  }

  search() {
    this.filter()
  }

  filterByStatus() {
    this.filter()
  }

  filterByBrand() {
    this.filter()
  }

  filter() {
    const searchTerm = this.hasSearchInputTarget ? this.searchInputTarget.value.toLowerCase() : ''
    const statusFilter = this.hasStatusFilterTarget ? this.statusFilterTarget.value : ''
    const brandFilter = this.hasBrandFilterTarget ? this.brandFilterTarget.value : ''

    const allVehicleElements = this.element.querySelectorAll('[data-vehicle-search]')

    allVehicleElements.forEach(element => {
      const searchData = element.dataset.vehicleSearch || ''
      const statusData = element.dataset.vehicleStatus || ''
      const brandData = element.dataset.vehicleBrand || ''

      const matchesSearch = !searchTerm || searchData.includes(searchTerm)
      const matchesStatus = !statusFilter || statusData === statusFilter
      const matchesBrand = !brandFilter || brandData === brandFilter

      const shouldShow = matchesSearch && matchesStatus && matchesBrand

      if (shouldShow) {
        element.style.display = ''
      } else {
        element.style.display = 'none'
      }
    })
  }
}