class AddLogsToPlans < ActiveRecord::Migration[7.1]
  def change
    add_column :plans, :logs, :text
  end
end

Vault::Rails.decrypt('transit', 'chushi_storage_url', 'vault:v1:azkTDZBEaD5mUu5zk9La5SRIJew1Zjqga61Mb9xZlv16W9lFRZLgfFmZXiiv2D49n9BE+HyrRr0JArh1SrBfBUzNdmbQ5amtDQG0eX+xdrLfmPHS7Nd3SwznL97ty5g1FFgYYXLZQixV2xuPxH/839rTZ+VwgGH/JT6ZtBArxnCa88wslA==')