class FixLinksConstraints < ActiveRecord::Migration[8.0]
  def up
    # Backfill any existing null click counts before enforcing NOT NULL/default.
    execute "UPDATE links SET clicks = 0 WHERE clicks IS NULL"
    change_column_default :links, :clicks, from: nil, to: 0
    change_column_null :links, :clicks, false, 0

    # Remove any pre-existing duplicate short_tokens (keep the oldest row) so the
    # unique index below can be added safely.
    execute <<~SQL
      DELETE FROM links
      WHERE id NOT IN (
        SELECT MIN(id) FROM links GROUP BY short_token
      )
    SQL

    remove_index :links, :short_token
    add_index :links, :short_token, unique: true
  end

  def down
    remove_index :links, :short_token
    add_index :links, :short_token
    change_column_null :links, :clicks, true
    change_column_default :links, :clicks, from: 0, to: nil
  end
end
