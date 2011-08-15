class GameObserver < ActiveRecord::Observer
	def after_save(game)
    update_points(game)
	end

private

  def update_points(game)
  	picks = Pick.where(:game_id => game)
		picks.each do |pick|
			pick.update_points(game.winner)
		end
  end
end