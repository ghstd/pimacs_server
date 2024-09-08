$TILE_SIZE = 32
$SERVER_COEFICIENT = 6

require 'json'
require 'set'
require 'singleton'
require 'securerandom'

require_relative "modules/pixels_converter"
require_relative "modules/pathfinder"
require_relative "modules/timeouts_registrator"
require_relative 'modules/id_generator'
require_relative "classes/individual_abilities/index"
require_relative "classes/world"
require_relative "classes/map"
require_relative "classes/monsters/index"
require_relative "classes/player"

class Game
  attr_accessor :stop
  def initialize
    @stop = false
    @world = World.instance
  end

  def player_move(id:, data:)
    current_player = nil
    x, y = data
    @world.maps.each do |map_name, map|
      player = map.players.find { |p| p.id == id }
      if player
        current_player = player
        break
      end
    end
    current_player.start_moving(x, y) if current_player
  end

  def create_player(id:, map_name:, x:, y:)
    player = Player.new(id: id, map_name: map_name, x: x, y: y)
    @world.maps[map_name].players << player
  end

  def delete_player(id:, map_name:)
    @world.maps[map_name].players.delete_if {|player| player.id == id}
  end

  def update
    TimeoutsRegistrator.update
    @world.maps.each {|name, map| map.update}

    data = @world.state

    ActionCable.server.broadcast('game_connect', data)
  end
end
