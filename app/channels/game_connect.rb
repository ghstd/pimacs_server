class GameConnect < ApplicationCable::Channel
  @@sibscribers = []

  def self.subscribers
    @@sibscribers
  end

  def subscribed
    stream_from "game_connect"
    # stream_for 'id_1'
    p 'subscribed'

    login = params[:login]
    password = params[:password]
    # ищем игрока в базе, получаем его информацию
    @player = {
      id: 1,
      map_name: '4',
      x: 192,
      y: 192
    }
    $game.create_player(**@player)
  end

  def unsubscribed
    p 'unsubscribed'
    # ищем игрока в базе, получаем его информацию через params
    $game.delete_player(id: 1, map_name: '4')
  end

  def player_move(data)
    $game.player_move(id: @player[:id], data: data['message'])
  end

  def create_projectile(data)
    p data
  end

end
