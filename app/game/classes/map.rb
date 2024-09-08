class Map
  attr_accessor :width, :height, :tile_layers, :all_tiles_info, :transition_areas,
  :players, :monsters, :projectiles, :animations
  TILE_SIZE = $TILE_SIZE
  def initialize(map_data)
    @map_data = map_data
    @width = @map_data['width']
    @height = @map_data['height']

    @tile_layers = []
    @object_layers = []

    @all_tiles_info = []
    @transition_areas = []

    @players = Set.new
    @monsters = Set.new
    @projectiles = Set.new

    init_layers
    init_tiles_info
    init_transition_areas
    TimeoutsRegistrator.add_timeout(observer: self, method: :init_monsters, delay: 20, type: :once)
  end

  def state
    {
      players: @players.map(&:state),
      monsters: @monsters.map(&:state),
      projectiles: @projectiles.map(&:state)
    }
  end

  def init_layers
    @map_data['layers'].each do |layer|
      case layer['type']
        when 'tilelayer'
          @tile_layers << layer
        when 'objectgroup'
          @object_layers << layer
      end
    end
  end

  def init_tiles_info
    @tile_layers.each do |layer|
      layer['data'].each_with_index do |tile_id, index|
        @map_data['tilesets'].each do |tileset|
          next if !(tileset['firstgid']..tileset['tilecount']).cover?(tile_id)
          tile = tileset['tiles'].find { |tile| tile['id'] == (tile_id - 1) }
          next unless tile
          if @all_tiles_info[index].nil?
            @all_tiles_info[index] = [tile]
          else
            @all_tiles_info[index] << tile
          end
        end
      end
    end
  end

  def init_transition_areas
    @object_layers.each do |layer|
      if layer['name'] == 'Transition'
        object = layer['objects'].each do |object|
          if object['name'] == 'transition'
            string = object['properties'].find { |prop| prop['name'] == 'destination' }['value']
            destination = {}
            string.split(',').each do |pair|
              key, value = pair.split(':')
              destination[key.to_sym] = value.to_i
            end

            @transition_areas << {
              x: object['x'],
              y: object['y'],
              width: object['width'],
              height: object['height'],
              to_map: object['properties'].find { |prop| prop['name'] == 'to_map' }['value'],
              destination: destination
            }
          end
        end
      end
    end
  end

  def init_monsters
    @object_layers.each do |layer|
      next unless layer['name'] == 'Monsters'
      layer['objects'].each do |object|
        quantity = object['properties'].find { |prop| prop['name'] == 'quantity' }['value']
        quantity.times do
          x1 = object['x']
          y1 = object['y']
          x2 = object['x'] + object['width'] - TILE_SIZE
          y2 = object['y'] + object['height'] - TILE_SIZE
          start = PixelsConverter.pixels_to_tile_coord(x1, y1)
          finish = PixelsConverter.pixels_to_tile_coord(x2, y2)
          x, y = PixelsConverter.tile_coord_to_pixels(rand(start[0]..finish[0]), rand(start[1]..finish[1]))
          monster = Object.const_get("Monsters::#{object['name']}").new(
            x: x,
            y: y,
            respawn_start: start,
            respawn_finish: finish
          )
          @monsters << monster
        end
      end
    end
  end

  def update
    @players.each(&:update)
    @monsters.each(&:update)
    @projectiles.each(&:update)
  end

end
