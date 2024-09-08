class World
  include Singleton
  attr_accessor :maps

  def initialize
    world_path = Rails.root.join('app', 'game', 'maps', 'game.world')
    @world = JSON.parse(File.read(world_path))

    @maps = {}
    @world['maps'].each do |map|
      map_name = File.basename(map['fileName'], File.extname(map['fileName']))
      map_path = Rails.root.join('app', 'game', 'maps', "#{map_name}.json")
      map_data = JSON.parse(File.read(map_path))
      @maps[map_name] = Map.new(map_data)
    end
  end

  def state
    state = {}
    @maps.each do |map_name, map|
      state[map_name] = map.state
    end
    return state
  end

end
