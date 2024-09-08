module Monsters
  class BasicClass
    attr_accessor :x, :y, :width, :height, :speed, :current_image,
      :target, :respawn_start, :respawn_finish, :xp, :spelling, :skills,
      :current_map
    def initialize(x:, y:, speed: 1, respawn_start: nil, respawn_finish: nil)
      @tile_size = $TILE_SIZE
      @half_tile_size = @tile_size / 2

      @world = World.instance
      @x = x
      @y = y
      @width = 32
      @height = 32
      @speed = speed

      @target = nil

      # @current_image = nil

      @spelling = false

      @id = IdGenerator.create_id
      @map_name = '5'
      @current_map = @world.maps[@map_name]

      @respawn_start = respawn_start || [0, 0]
      @respawn_finish = respawn_finish || PixelsConverter.pixels_to_tile_coord(@current_map.width - @tile_size, @current_map.height - @tile_size)

      @xp = 100

      @skills = {}
    end

    def state
      {
        id: @id,
        map_name: @map_name,
        x: @x,
        y: @y
      }
    end

    def add_skill(skill)
      @skills[skill.class] = skill
    end

    def get_hit(projectile)
      p "#{self.class} hit"
    end

    def update

    end

    def draw

    end
  end

end