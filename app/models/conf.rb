class Conf < ActiveRecord::Base
  attr_accessible :key, :value
end


def self.getvalue(key)
  Conf.find_by_key(key).value
end