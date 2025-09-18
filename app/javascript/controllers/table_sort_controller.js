import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["table"]

  connect() {
    this.addSortHandlers()
  }

  addSortHandlers() {
    const headers = this.tableTarget.querySelectorAll('thead th[data-sortable]')

    headers.forEach(header => {
      header.style.cursor = 'pointer'
      header.classList.add('is-clickable')

      if (!header.querySelector('.sort-icon')) {
        const icon = document.createElement('span')
        icon.className = 'sort-icon icon is-small ml-1'
        icon.innerHTML = '<i class="fas fa-sort"></i>'
        header.appendChild(icon)
      }

      header.addEventListener('click', () => this.sortTable(header))
    })
  }

  sortTable(header) {
    const table = this.tableTarget
    const tbody = table.querySelector('tbody')
    const rows = Array.from(tbody.querySelectorAll('tr'))
    const columnIndex = Array.from(header.parentNode.children).indexOf(header)
    const dataType = header.dataset.sortType || 'string'

    const currentDirection = header.dataset.sortDirection || 'asc'
    const newDirection = currentDirection === 'asc' ? 'desc' : 'asc'

    table.querySelectorAll('th').forEach(th => {
      th.removeAttribute('data-sort-direction')
      const icon = th.querySelector('.sort-icon i')
      if (icon) icon.className = 'fas fa-sort'
    })

    header.dataset.sortDirection = newDirection
    const sortIcon = header.querySelector('.sort-icon i')
    if (sortIcon) {
      sortIcon.className = newDirection === 'asc' ? 'fas fa-sort-up' : 'fas fa-sort-down'
    }

    rows.sort((a, b) => {
      const aCell = a.children[columnIndex]
      const bCell = b.children[columnIndex]

      let aValue = this.getCellValue(aCell, dataType)
      let bValue = this.getCellValue(bCell, dataType)

      if (dataType === 'number') {
        aValue = parseFloat(aValue) || 0
        bValue = parseFloat(bValue) || 0
      } else if (dataType === 'date') {
        aValue = new Date(aValue)
        bValue = new Date(bValue)
      }

      let comparison = 0
      if (aValue > bValue) comparison = 1
      if (aValue < bValue) comparison = -1

      return newDirection === 'asc' ? comparison : -comparison
    })

    rows.forEach(row => tbody.appendChild(row))
  }

  getCellValue(cell, dataType) {
    if (cell.dataset.sortValue) {
      return cell.dataset.sortValue
    }

    let value = cell.textContent.trim()

    if (dataType === 'number') {
      value = value.replace(/[$,\s]/g, '')
    }

    return value
  }
}