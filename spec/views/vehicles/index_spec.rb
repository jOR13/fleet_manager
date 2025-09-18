require 'rails_helper'

RSpec.describe "vehicles/index", type: :view do
  let(:vehicles) do
    [
      create(:vehicle,
        vin: 'WBAJW5C50EG123456',
        plate: 'ABC-123',
        brand: 'BMW',
        model: 'X5',
        year: 2020,
        status: 'active',
        mileage: 45000
      ),
      create(:vehicle,
        vin: 'WBAJW5C50EG789012',
        plate: 'DEF-456',
        brand: 'Toyota',
        model: 'Camry',
        year: 2019,
        status: 'in_maintenance',
        mileage: 52000
      )
    ]
  end

  let(:pagy) { double('Pagy', pages: 1, page: 1, count: 2, vars: { items: 20 }, next: nil, prev: nil, limit: 20) }

  before do
    assign(:vehicles, vehicles)
    assign(:pagy, pagy)
    assign(:search, '')
    assign(:status_filter, '')
    assign(:brand_filter, '')
    assign(:view_mode, 'cards')
  end

  it "renders a list of vehicles" do
    render

    expect(rendered).to match(/BMW X5/)
    expect(rendered).to match(/Toyota Camry/)
    expect(rendered).to match(/ABC-123/)
    expect(rendered).to match(/DEF-456/)
  end

  it "displays vehicle statuses" do
    render

    expect(rendered).to match(/Active/)
    expect(rendered).to match(/In Maintenance/)
  end

  it "shows vehicle mileage" do
    render

    expect(rendered).to match(/45,000/)
    expect(rendered).to match(/52,000/)
  end

  it "includes VIN numbers" do
    render

    expect(rendered).to match(/WBAJW5C50EG123456/)
    expect(rendered).to match(/WBAJW5C50EG789012/)
  end

  it "displays vehicle years" do
    render

    expect(rendered).to match(/2020/)
    expect(rendered).to match(/2019/)
  end

  it "includes action links" do
    render

    expect(rendered).to have_link('View', href: vehicle_path(vehicles.first))
    expect(rendered).to have_link('Edit', href: edit_vehicle_path(vehicles.first))
  end

  context "when no vehicles exist" do
    let(:vehicles) { [] }
    let(:pagy) { double('Pagy', pages: 0, page: 1, count: 0, vars: { items: 20 }, next: nil, prev: nil, limit: 20) }

    before do
      assign(:vehicles, vehicles)
      assign(:pagy, pagy)
    end

    it "displays a no vehicles message" do
      render

      expect(rendered).to match(/No vehicles registered/)
    end
  end

  context "with search and filters" do
    before do
      assign(:search, 'BMW')
      assign(:status_filter, 'active')
      assign(:brand_filter, 'BMW')
    end

    it "displays search form with current values" do
      render

      expect(rendered).to have_field('search', with: 'BMW')
      expect(rendered).to have_select('status', selected: 'active')
      expect(rendered).to have_select('brand', selected: 'BMW')
    end
  end

  context "with table view mode" do
    before do
      assign(:view_mode, 'table')
    end

    it "renders table view elements" do
      render

      expect(rendered).to have_css('table')
      expect(rendered).to have_css('thead')
      expect(rendered).to have_css('tbody')
    end
  end

  context "with internationalization" do
    it "displays translated content" do
      render

      expect(rendered).to match(/Vehículos/)
      expect(rendered).to match(/Nuevo Vehículo/)
    end
  end

  context "pagination" do
    it "includes pagination information" do
      render

      expect(rendered).to match(/2/)
    end
  end
end
