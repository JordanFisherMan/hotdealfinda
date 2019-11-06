class ChannelNotNeeded < ActiveRecord::Migration[5.2]
  def change
    remove_column :deals, :channel
  end
end
