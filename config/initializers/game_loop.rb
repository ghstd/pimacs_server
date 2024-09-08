require_relative '../../app/game/game'

$game = Game.new

Thread.new do
  loop do
    begin
      if $game.stop
        p 'Game stopped'
        break
      end
      $game.update
      sleep(1.0 / 10)
    rescue => e
      Rails.logger.error "Ошибка в игровом цикле: #{e.backtrace.first}"
      Rails.logger.error "=============================================="
    end
  end
end
