module Projectiles
  class BasicClass
    attr_reader :x, :y, :size, :id

    def initialize(owner:, target: nil, start_x:, start_y:, target_x:,
      target_y:, speed:, size: 8, id: nil, map_name:, type: 'RedBall')
      @owner = owner
      @map_name = map_name
      @current_map = World.instance.maps[@map_name]

      @target = target
      @x = start_x
      @y = start_y
      @target_x = target_x
      @target_y = target_y
      @speed = speed * $SERVER_COEFICIENT
      @size = size

      @id = id || IdGenerator.create_id

      @type = type

      @reached_target = false

      set_movement_direction
    end

    def state
      {
        owner_id: @owner.id,
        target_id: @target ? @target.id : nil,
        x: @x,
        y: @y,
        target_x: @target_x,
        target_y: @target_y,
        speed: @speed / $SERVER_COEFICIENT,
        size: @size,
        id: @id,
        map_name: @map_name,
        type: @type,
      }
    end

    def set_movement_direction
      if @target
        @target_x = @target.x + @target.width / 2
        @target_y = @target.y + @target.height / 2
      end
      dx = @target_x - @x
      dy = @target_y - @y
      distance = Math.sqrt(dx**2 + dy**2)
      @velocity_x = (dx / distance) * @speed
      @velocity_y = (dy / distance) * @speed
    end

    def reached_target?
      ( (@x - @target_x).abs < @speed ) && ( (@y - @target_y).abs < @speed )
    end

    def delete_projectile
      if !@reached_target
        sign_x = @velocity_x <=> 0
        sign_y = @velocity_y <=> 0
        @x += sign_x * $TILE_SIZE / 8
        @y += sign_y * $TILE_SIZE / 8
      end
      @current_map.projectiles.delete(self)
    end

    def update
      if @target && (@target.x != @target_x || @target.y != @target_y)
        set_movement_direction
      end

      @x += @velocity_x
      @y += @velocity_y

      # colliding with barriers
      current_tile_x, current_tile_y = PixelsConverter.pixels_to_tile_coord(@x, @y)
      tile_index = current_tile_x + current_tile_y * @current_map.width
      tiles = @current_map.all_tiles_info[tile_index]

      tiles_collides = tiles.map do |tile|
        tile['properties'].filter {|prop| prop['name'] == 'collides'}.map {|prop| prop['value']}
      end
      collides = tiles_collides.flatten.include?(true)

      # colliding with tiles
      if collides
        delete_projectile
        return
      end

      # colliding with monsters
      monster = @current_map.monsters.find do |monster|
        monster_x, monster_y = PixelsConverter.pixels_to_tile_coord(monster.x, monster.y)
        (monster_x == current_tile_x) && (monster_y == current_tile_y)
      end

      # p monster.class if monster

      if monster && monster != @owner
        monster.get_hit(self)
        delete_projectile
        return
      end

      # colliding with players
      player = @current_map.players.find do |player|
        player_x, player_y = PixelsConverter.pixels_to_tile_coord(player.x, player.y)
        (player_x == current_tile_x) && (player_y == current_tile_y)
      end

      if player && player != @owner
        player.get_hit(self)
        delete_projectile
        return
      end

      # reached_target
      if reached_target?
        @reached_target = true
        delete_projectile
      end
    end

  end

end
