import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggleButton", "icon", "text"]

  connect() {
    const savedTheme = localStorage.getItem('theme') || 'light'
    this.setTheme(savedTheme)
  }

  toggle() {
    const currentTheme = document.documentElement.getAttribute('data-theme')
    const newTheme = currentTheme === 'light' ? 'dark' : 'light'
    this.setTheme(newTheme)
  }

  setTheme(theme) {
    document.documentElement.setAttribute('data-theme', theme)
    localStorage.setItem('theme', theme)

    if (this.hasIconTarget && this.hasTextTarget) {
      if (theme === 'dark') {
        this.iconTarget.className = 'fas fa-sun'
        this.textTarget.textContent = 'Claro'
      } else {
        this.iconTarget.className = 'fas fa-moon'
        this.textTarget.textContent = 'Oscuro'
      }
    }
  }
}