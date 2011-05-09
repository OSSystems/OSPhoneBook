ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  fixtures :all

  def default_hash(model, more_data = {})
    case model.to_s
    when Company.to_s
      data_hash = {:name => "Placebo S.A"}
    when Contact.to_s
      data_hash = {:name => "John Doe",
        :company => Company.create(default_hash(Company))}
    when PhoneNumber.to_s
      data_hash = {:number => "1234-5678", :phone_type => 1,
        :contact => Contact.create(default_hash(Contact))}
    else
      raise "Unknown model #{model.to_s}!"
    end

    return data_hash.merge(more_data)
  end
end
