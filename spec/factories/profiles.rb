# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
	factory :profile do
		gender "MyString"
		first_name "MyString"
		last_name "MyString"
		displayed_as "MyString"
		mobile_no "MyString"
		birth_year "MyString"
		mini_bio "MyText"
	end
end
