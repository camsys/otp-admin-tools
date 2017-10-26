class AddViewableUrl < ActiveRecord::Migration[5.0]
  def change
    add_column :results, :otp_viewable_request, :text
  end
end
