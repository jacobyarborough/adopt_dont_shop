require 'rails_helper'

RSpec.describe 'the admin applications show page' do 
  it 'can approve or reject pets on an application' do 
    shelter1 = Shelter.create!(foster_program: true,
                           name: 'Rocky Mountain Dog Shelter',
                           city: 'Denver',
                           rank: 1)
    pet1 = shelter1.pets.create!(adoptable: true,
                           age: 3,
                           breed: "Labrador Retriever",
                           name: 'Bailey')
    pet2 = shelter1.pets.create!(adoptable: true,
                           age: 1,
                           breed: "French Bulldog",
                           name: 'Bella')
    application1 = Application.create!(applicant_name: 'Jacob Yarborough', 
                           street_address: '123 Main Street', 
                           city: 'Denver', 
                           state: 'CO',
                           zipcode: '80223',
                           application_status: 'Pending',
                           why: 'I love dogs')
    application1.pets << pet1
    application1.pets << pet2

    visit ("/admin/applications/#{application1.id}")

    expect(current_path).to eq("/admin/applications/#{application1.id}")

    within "#pets_on_app" do 
      expect(page).to have_content(pet1.name)
      expect(page).to have_content(pet2.name)

      click_on "Approve #{pet1.name}"
    end 

    expect(current_path).to eq("/admin/applications/#{application1.id}")

    within "#pets_on_app" do 
      expect(page).to have_content(pet1.name)
      expect(page).to have_content(pet2.name)
      expect(page).not_to have_content("Approve #{pet1.name}")
      expect(page).not_to have_content("Reject #{pet1.name}")
      expect(page).to have_content("#{pet1.name} Approved")

      click_on "Reject #{pet2.name}"
    end 

    expect(current_path).to eq("/admin/applications/#{application1.id}")

    within "#pets_on_app" do 
      expect(page).to have_content(pet1.name)
      expect(page).to have_content(pet2.name)
      expect(page).not_to have_content("Approve #{pet1.name}")
      expect(page).not_to have_content("Reject #{pet1.name}")
      expect(page).not_to have_content("Approve #{pet2.name}")
      expect(page).not_to have_content("Reject #{pet2.name}")
      expect(page).to have_content("#{pet1.name} Approved")
      expect(page).to have_content("#{pet2.name} Rejected")
    end 
  end 

  it 'does not affect other applications when a pet is approved' do 
    shelter1 = Shelter.create!(foster_program: true,
        name: 'Rocky Mountain Dog Shelter',
        city: 'Denver',
        rank: 1)
    pet1 = shelter1.pets.create!(adoptable: true,
        age: 3,
        breed: "Labrador Retriever",
        name: 'Bailey')
    pet2 = shelter1.pets.create!(adoptable: true,
        age: 1,
        breed: "French Bulldog",
        name: 'Bella')
    application1 = Application.create!(applicant_name: 'Jacob Yarborough', 
        street_address: '123 Main Street', 
        city: 'Denver', 
        state: 'CO',
        zipcode: '80223',
        application_status: 'Pending',
        why: 'I love dogs')
    application2 = Application.create!(applicant_name: 'Joe Smith', 
        street_address: '456 North Street', 
        city: 'Denver', 
        state: 'CO',
        zipcode: '80202',
        application_status: 'Pending',
        why: 'I currently have two other dogs')
    application1.pets << pet1
    application1.pets << pet2
    application2.pets << pet1
    application2.pets << pet2

    visit ("/admin/applications/#{application1.id}")

    expect(current_path).to eq("/admin/applications/#{application1.id}")

    click_on "Approve #{pet1.name}"

    expect(current_path).to eq("/admin/applications/#{application1.id}")

    visit "/admin/applications/#{application2.id}"

    expect(current_path).to eq("/admin/applications/#{application2.id}")

    within "#pets_on_app" do 
      expect(page).to have_button("Approve #{pet1.name}")
      expect(page).to have_button("Reject #{pet1.name}")
      expect(page).to have_button("Approve #{pet2.name}")
      expect(page).to have_button("Reject #{pet2.name}")
    end 
  end
end 