class Player
  attr_accessor :x, :y, :width, :height, :speed, :current_image,
    :target, :xp, :mp, :spelling, :skills, :id, :state, :timestamp

  include IndividualAbilities::Move

  def initialize(id:, map_name:, x:, y:)
    @tile_size = $TILE_SIZE
    @half_tile_size = @tile_size / 2

    @world = World.instance
    @x = x
    @y = y
    @width = 32
    @height = 32
    @speed = 2 * $SERVER_COEFICIENT

    @target = nil

    # @current_image = nil

    @spelling = false

    @xp = 100
    @mp = 100

    @id = id
    @map_name = map_name
    @current_map = @world.maps[@map_name]

    init_move_module

    @timestamp = Time.now

    # '=================================='

    # @skills = {}

    # add_skill(Skills::RedBall.new(owner: self))
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

  def player_in_area?(area)
    @x < area[:x] + area[:width] &&
      @x + @tile_size > area[:x] &&
      @y < area[:y] + area[:height] &&
      @y + @tile_size > area[:y]
  end

  def draw_player_target
    return unless @target

    if @target.is_a? Array
      target_tile_x, target_tile_y = @target
      target_x = target_tile_x * @tile_size
      target_y = target_tile_y * @tile_size
    else
      target_x = @target.x
      target_y = @target.y
    end

    p1_x = target_x
    p1_y = target_y

    p2_x = target_x + @tile_size
    p2_y = target_y

    p3_x = target_x + @tile_size
    p3_y = target_y + @tile_size

    p4_x = target_x
    p4_y = target_y + @tile_size

    color = Gosu::Color::RED

    Gosu.draw_line(p1_x, p1_y, color, p2_x, p2_y, color)
    Gosu.draw_line(p2_x, p2_y, color, p3_x, p3_y, color)
    Gosu.draw_line(p3_x, p3_y, color, p4_x, p4_y, color)
    Gosu.draw_line(p4_x, p4_y, color, p1_x, p1_y, color)
  end

  def draw_target_xp_bar
    return unless @target
    return unless !@target.is_a? Array

    Gosu.draw_rect(200, 20, @target.xp, 10, Gosu::Color::RED, 3)
  end

  def draw_xp_mp_bars
    Gosu.draw_rect(30, 60, 20, @xp * 2, Gosu::Color::RED, 3)
    Gosu.draw_rect(60, 60, 20, @xp * 2, Gosu::Color.new(255, 19, 103, 138), 3)
  end

  def update
    # current_time = Time.now
    # elapsed_time = current_time - @timestamp
    # @speed = @speed * elapsed_time
    # @timestamp = current_time

    move
  end

  def draw
    draw_player_target
  end
end
