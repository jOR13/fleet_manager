import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "vinField", "vinError",
    "brandField", "brandError",
    "modelField", "modelError",
    "yearField", "yearError",
    "plateField", "plateError",
    "mileageField", "mileageError",
    "submitButton"
  ]

  connect() {
    this.validateForm()
  }

  validateField(event) {
    const field = event.target
    const fieldName = field.name.split('[')[1].split(']')[0]
    this.validateSingleField(fieldName, field)
    this.validateForm()
  }

  validateSingleField(fieldName, field) {
    const value = field.value.trim()
    let isValid = true
    let errorMessage = ""

    switch(fieldName) {
      case 'vin':
        if (!value) {
          isValid = false
          errorMessage = "El VIN es requerido"
        } else if (value.length !== 17) {
          isValid = false
          errorMessage = "El VIN debe tener exactamente 17 caracteres"
        }
        break

      case 'brand':
        if (!value) {
          isValid = false
          errorMessage = "La marca es requerida"
        } else if (value.length < 2) {
          isValid = false
          errorMessage = "La marca debe tener al menos 2 caracteres"
        }
        break

      case 'model':
        if (!value) {
          isValid = false
          errorMessage = "El modelo es requerido"
        } else if (value.length < 1) {
          isValid = false
          errorMessage = "El modelo debe tener al menos 1 caracter"
        }
        break

      case 'year':
        const year = parseInt(value)
        const currentYear = new Date().getFullYear()
        if (!value) {
          isValid = false
          errorMessage = "El año es requerido"
        } else if (year < 1900 || year > currentYear + 1) {
          isValid = false
          errorMessage = `El año debe estar entre 1900 y ${currentYear + 1}`
        }
        break

      case 'plate':
        if (!value) {
          isValid = false
          errorMessage = "La placa es requerida"
        } else if (value.length < 3) {
          isValid = false
          errorMessage = "La placa debe tener al menos 3 caracteres"
        }
        break

      case 'mileage':
        const mileage = parseInt(value)
        if (value && mileage < 0) {
          isValid = false
          errorMessage = "El kilometraje no puede ser negativo"
        }
        break
    }

    this.showFieldError(fieldName, isValid, errorMessage)
    return isValid
  }

  showFieldError(fieldName, isValid, errorMessage) {
    const field = this[`${fieldName}FieldTarget`]
    const errorElement = this[`${fieldName}ErrorTarget`]

    if (isValid) {
      field.classList.remove('is-danger')
      field.classList.add('is-success')
      errorElement.classList.add('is-hidden')
      errorElement.textContent = ""
    } else {
      field.classList.remove('is-success')
      field.classList.add('is-danger')
      errorElement.classList.remove('is-hidden')
      errorElement.textContent = errorMessage
    }
  }

  validateForm() {
    const fields = ['vin', 'brand', 'model', 'year', 'plate']
    let allValid = true

    fields.forEach(fieldName => {
      const field = this[`${fieldName}FieldTarget`]
      if (field && !this.validateSingleField(fieldName, field)) {
        allValid = false
      }
    })

    const vinValue = this.vinFieldTarget.value.trim()
    const brandValue = this.brandFieldTarget.value.trim()
    const modelValue = this.modelFieldTarget.value.trim()
    const yearValue = this.yearFieldTarget.value.trim()
    const plateValue = this.plateFieldTarget.value.trim()

    if (!vinValue || !brandValue || !modelValue || !yearValue || !plateValue) {
      allValid = false
    }

    this.submitButtonTarget.disabled = !allValid

    if (allValid) {
      this.submitButtonTarget.classList.remove('is-loading')
    }
  }

  formatPlate(event) {
    let value = event.target.value.toUpperCase()
    if (value.length > 3 && !value.includes('-')) {
      value = value.slice(0, 3) + '-' + value.slice(3)
    }
    event.target.value = value
  }

  formatVin(event) {
    let value = event.target.value.toUpperCase()
    value = value.replace(/[^A-Z0-9]/g, '').substring(0, 17)
    event.target.value = value
  }
}