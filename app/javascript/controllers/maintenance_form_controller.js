import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "serviceTypeField", "serviceTypeError",
    "serviceDateField", "serviceDateError",
    "descriptionField", "descriptionError",
    "costField", "costError",
    "mileageField", "mileageError",
    "submitButton",
    "additionalFields",
    "oilChangeFields",
    "oilTypeField",
    "nextOilChangeField"
  ]

  connect() {
    this.validateForm()
  }

  handleTypeChange(event) {
    const serviceType = event.target.value
    this.showAdditionalFields(serviceType)
    this.validateForm()
  }

  showAdditionalFields(serviceType) {
    if (this.hasAdditionalFieldsTarget) {
      if (serviceType === 'Cambio de Aceite') {
        this.additionalFieldsTarget.classList.remove('is-hidden')
        this.oilChangeFieldsTarget.classList.remove('is-hidden')
      } else {
        this.additionalFieldsTarget.classList.add('is-hidden')
        this.oilChangeFieldsTarget.classList.add('is-hidden')
      }
    }
  }

  validateField(event) {
    const field = event.target
    const fieldName = this.getFieldName(field)
    this.validateSingleField(fieldName, field)
    this.validateForm()
  }

  getFieldName(field) {
    const name = field.name
    if (name.includes('[')) {
      return name.split('[')[1].split(']')[0]
    }
    return name
  }

  validateSingleField(fieldName, field) {
    const value = field.value.trim()
    let isValid = true
    let errorMessage = ""

    switch(fieldName) {
      case 'service_type':
        if (!value) {
          isValid = false
          errorMessage = "El tipo de servicio es requerido"
        }
        break

      case 'service_date':
        if (!value) {
          isValid = false
          errorMessage = "La fecha del servicio es requerida"
        } else {
          const serviceDate = new Date(value)
          const today = new Date()
          if (serviceDate > today) {
            isValid = false
            errorMessage = "La fecha no puede ser futura"
          }
        }
        break

      case 'description':
        if (!value) {
          isValid = false
          errorMessage = "La descripción es requerida"
        } else if (value.length < 10) {
          isValid = false
          errorMessage = "La descripción debe tener al menos 10 caracteres"
        }
        break

      case 'cost':
        if (value) {
          const cost = parseFloat(value)
          if (cost < 0) {
            isValid = false
            errorMessage = "El costo no puede ser negativo"
          }
        }
        break

      case 'mileage_at_service':
        if (value) {
          const mileage = parseInt(value)
          if (mileage < 0) {
            isValid = false
            errorMessage = "El kilometraje no puede ser negativo"
          }
        }
        break
    }

    this.showFieldError(fieldName, isValid, errorMessage)
    return isValid
  }

  showFieldError(fieldName, isValid, errorMessage) {
    const field = this[`${fieldName}FieldTarget`]
    const errorElement = this[`${fieldName}ErrorTarget`]

    if (!field || !errorElement) return

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
    const requiredFields = ['service_type', 'service_date', 'description']
    let allValid = true

    requiredFields.forEach(fieldName => {
      const field = this[`${fieldName}FieldTarget`]
      if (field && !this.validateSingleField(fieldName, field)) {
        allValid = false
      }
    })

    // Check if required fields have values
    const serviceTypeValue = this.serviceTypeFieldTarget.value.trim()
    const serviceDateValue = this.serviceDateFieldTarget.value.trim()
    const descriptionValue = this.descriptionFieldTarget.value.trim()

    if (!serviceTypeValue || !serviceDateValue || !descriptionValue) {
      allValid = false
    }

    this.submitButtonTarget.disabled = !allValid

    if (allValid) {
      this.submitButtonTarget.classList.remove('is-loading')
    }
  }

  formatCurrency(event) {
    const field = event.target
    let value = field.value

    value = value.replace(/[^0-9.]/g, '')

    const parts = value.split('.')
    if (parts.length > 2) {
      value = parts[0] + '.' + parts.slice(1).join('')
    }

    if (parts[1] && parts[1].length > 2) {
      value = parts[0] + '.' + parts[1].substring(0, 2)
    }

    field.value = value
    this.validateField(event)
  }

  validateMileage(event) {
    const field = event.target
    const mileage = parseInt(field.value)

    if (field.value && mileage >= 0) {
      field.classList.add('is-success')
      field.classList.remove('is-danger')
    }

    this.validateField(event)
  }

  calculateNextOilChange() {
    if (this.hasOilChangeFieldsTarget && this.hasMileageFieldTarget) {
      const currentMileage = parseInt(this.mileageFieldTarget.value) || 0
      const recommendedInterval = 5000
      const nextMileage = currentMileage + recommendedInterval

      if (this.hasNextOilChangeFieldTarget) {
        this.nextOilChangeFieldTarget.value = nextMileage
      }
    }
  }
}