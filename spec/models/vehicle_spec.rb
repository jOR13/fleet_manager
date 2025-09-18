require 'rails_helper'

RSpec.describe Vehicle, type: :model do
  let(:valid_attributes) do
    {
      vin: 'WBAJW5C50EG123456',
      plate: 'ABC-123',
      brand: 'BMW',
      model: 'X5',
      year: 2020,
      status: 'active'
    }
  end

  describe 'validations' do
    subject { Vehicle.new(valid_attributes) }

    it 'is valid with valid attributes' do
      expect(subject).to be_valid
    end

    describe 'VIN validation' do
      it 'requires VIN to be present' do
        subject.vin = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:vin]).to include("can't be blank")
      end

      it 'requires VIN to be exactly 17 characters' do
        subject.vin = '12345'
        expect(subject).not_to be_valid
        expect(subject.errors[:vin]).to include('is the wrong length (should be 17 characters)')
      end

      it 'requires VIN to be unique (case-insensitive)' do
        create(:vehicle, vin: 'WBAJW5C50EG123456')
        subject.vin = 'wbajw5c50eg123456'
        expect(subject).not_to be_valid
        expect(subject.errors[:vin]).to include('has already been taken')
      end
    end

    describe 'plate validation' do
      it 'requires plate to be present' do
        subject.plate = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:plate]).to include("can't be blank")
      end

      it 'requires plate to be unique (case-insensitive)' do
        create(:vehicle, plate: 'ABC-123')
        subject.plate = 'abc-123'
        expect(subject).not_to be_valid
        expect(subject.errors[:plate]).to include('has already been taken')
      end
    end

    describe 'year validation' do
      it 'requires year to be between 1990 and 2050' do
        subject.year = 1989
        expect(subject).not_to be_valid
        expect(subject.errors[:year]).to include('is not included in the list')

        subject.year = 2051
        expect(subject).not_to be_valid
        expect(subject.errors[:year]).to include('is not included in the list')
      end

      it 'accepts valid years' do
        subject.year = 1990
        expect(subject).to be_valid

        subject.year = 2050
        expect(subject).to be_valid

        subject.year = 2020
        expect(subject).to be_valid
      end
    end

    describe 'mileage validation' do
      it 'accepts nil mileage' do
        subject.mileage = nil
        expect(subject).to be_valid
      end

      it 'requires mileage to be non-negative' do
        subject.mileage = -1
        expect(subject).not_to be_valid
        expect(subject.errors[:mileage]).to include('must be greater than or equal to 0')
      end

      it 'accepts zero and positive mileage' do
        subject.mileage = 0
        expect(subject).to be_valid

        subject.mileage = 50000
        expect(subject).to be_valid
      end
    end

    it 'requires brand, model, and status to be present' do
      subject.brand = nil
      subject.model = nil
      subject.status = nil

      expect(subject).not_to be_valid
      expect(subject.errors[:brand]).to include("can't be blank")
      expect(subject.errors[:model]).to include("can't be blank")
      expect(subject.errors[:status]).to include("can't be blank")
    end
  end

  describe 'enums' do
    it 'defines status enum correctly' do
      expect(Vehicle.statuses).to eq({
        'active' => 'active',
        'inactive' => 'inactive',
        'in_maintenance' => 'in_maintenance'
      })
    end
  end

  describe 'callbacks' do
    it 'converts VIN and plate to uppercase before saving' do
      vehicle = Vehicle.create!(valid_attributes.merge(
        vin: 'wbajw5c50eg123456',
        plate: 'abc-123'
      ))

      expect(vehicle.vin).to eq('WBAJW5C50EG123456')
      expect(vehicle.plate).to eq('ABC-123')
    end
  end

  describe 'scopes' do
    let!(:active_vehicle) { create(:vehicle, status: 'active', brand: 'BMW') }
    let!(:inactive_vehicle) { create(:vehicle, status: 'inactive', brand: 'Toyota') }

    describe '.by_status' do
      it 'filters vehicles by status' do
        expect(Vehicle.by_status('active')).to include(active_vehicle)
        expect(Vehicle.by_status('active')).not_to include(inactive_vehicle)
      end

      it 'returns all vehicles when status is blank' do
        expect(Vehicle.by_status('').count).to eq(2)
        expect(Vehicle.by_status(nil).count).to eq(2)
      end
    end

    describe '.by_brand' do
      it 'filters vehicles by brand' do
        expect(Vehicle.by_brand('BMW')).to include(active_vehicle)
        expect(Vehicle.by_brand('BMW')).not_to include(inactive_vehicle)
      end
    end

    describe '.search' do
      it 'searches across VIN, plate, brand, and model' do
        results = Vehicle.search('BMW')
        expect(results).to include(active_vehicle)
        expect(results).not_to include(inactive_vehicle)
      end

      it 'is case insensitive' do
        results = Vehicle.search('bmw')
        expect(results).to include(active_vehicle)
      end
    end
  end

  describe '#update_maintenance_status!' do
    let(:vehicle) { create(:vehicle, status: 'active') }

    context 'when vehicle has pending or in_progress services' do
      it 'sets status to in_maintenance' do
        create(:maintenance_service, vehicle: vehicle, status: 'pending')

        vehicle.update_maintenance_status!
        expect(vehicle.status).to eq('in_maintenance')
      end

      it 'handles in_progress services' do
        create(:maintenance_service, vehicle: vehicle, status: 'in_progress')

        vehicle.update_maintenance_status!
        expect(vehicle.status).to eq('in_maintenance')
      end
    end

    context 'when vehicle has no pending or in_progress services' do
      it 'sets status to active if not inactive' do
        create(:maintenance_service, vehicle: vehicle, status: 'completed')

        vehicle.update_maintenance_status!
        expect(vehicle.status).to eq('active')
      end

      it 'keeps inactive status if vehicle is inactive' do
        vehicle.update!(status: 'inactive')
        create(:maintenance_service, vehicle: vehicle, status: 'completed')

        vehicle.update_maintenance_status!
        expect(vehicle.status).to eq('inactive')
      end
    end

    context 'when vehicle has mixed service statuses' do
      it 'prioritizes pending/in_progress over completed' do
        create(:maintenance_service, vehicle: vehicle, status: 'completed')
        create(:maintenance_service, vehicle: vehicle, status: 'pending')

        vehicle.update_maintenance_status!
        expect(vehicle.status).to eq('in_maintenance')
      end
    end
  end

  describe 'associations' do
    it 'has many maintenance services' do
      association = Vehicle.reflect_on_association(:maintenance_services)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end

    it 'destroys associated maintenance services when deleted' do
      vehicle = create(:vehicle)
      service = create(:maintenance_service, vehicle: vehicle)

      expect { vehicle.destroy }.to change(MaintenanceService, :count).by(-1)
    end
  end
end
