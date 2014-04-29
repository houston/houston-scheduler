module Houston::Scheduler
  class Configuration
    
    def initialize
      @use_planning_poker = true
      @use_mixer = true
      @use_velocity = true
      config = Houston.config.module(:scheduler).config
      instance_eval(&config) if config
    end
    
    def planning_poker(arg)
      @use_planning_poker = false if arg == :off
    end
    
    def mixer(arg)
      @use_mixer = false if arg == :off
    end
    
    def velocity(arg)
      @use_velocity = false if arg == :off
    end
    
    def use_planning_poker?
      @use_planning_poker
    end
    
    def use_mixer?
      @use_mixer
    end
    
    def use_velocity?
      @use_velocity
    end
    
  end
end
