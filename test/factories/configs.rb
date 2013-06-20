# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :config, :class => 'Configs' do
    key "MyString"
    value "MyString"
  end
end
