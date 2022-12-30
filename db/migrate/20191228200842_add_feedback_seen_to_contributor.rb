class AddFeedbackSeenToContributor < ActiveRecord::Migration[5.2]
  def change
    add_column :contributors, :feedback_seen, :boolean, default: false
  
    # Default for new contributor entries should be false, but existing ones after migration should be true
    reversible do |d|
      d.up {
        Contributor.all.each do |c|
          c.feedback_seen = true;
          c.save!
        end
      }
      d.down {}
    end


  end
end
