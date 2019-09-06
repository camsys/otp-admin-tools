class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  # monkey patch for rails 5.0.7, devise, partitioned active record path
  # something in trackable calls .id_in_database which doesn't exist in rails 5.0.7 but only in 5.2
  # and then screws up in the partitioned patch
  def id_in_database
    id
  end
end
