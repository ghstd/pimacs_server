module Monsters
  class Slime < Monsters::BasicClass

    include IndividualAbilities::Move

    def initialize(x:, y:, speed: 1, respawn_start: nil, respawn_finish: nil)
      super(
        x: x,
        y: y,
        speed: speed,
        respawn_start: respawn_start,
        respawn_finish: respawn_finish
      )

      init_move_module

      # add_skill(Skills::SlimeMud.new(owner: self))

      @move_random = IndividualAbilities::MoveRandom.new(owner: self)
      @detect_in_radius = IndividualAbilities::DetectInRadius.new(
        owner: self,
        radius: 2
      )
    end

    def action_start
      @in_action = true
      stop_on_nearest_tile
      @move_random.timeout.stop
      # @skills[Skills::SlimeMud].use_skill
      @spelling = true

      projectile = Projectiles::BasicClass.new(
        owner: self,
        target: @target,
        start_x: @x + @half_tile_size,
        start_y: @y + @half_tile_size,
        target_x: @target.x + @half_tile_size,
        target_y: @target.y + @half_tile_size,
        speed: 3,
        size: 10,
        map_name: @map_name,
        type: 'SlimeMud'
      )
      @current_map.projectiles << projectile

      TimeoutsRegistrator.add_timeout(
        observer: self,
        method: :action_done,
        delay: 120,
        type: :once
      )
    end

    def action_done
      @in_action = false
      @spelling = false
      @move_random.timeout.run unless @target
    end

    def update
      super
      move

      if @target && !@in_action
        action_start
      end
    end

    def draw
      super
    end
  end
end
