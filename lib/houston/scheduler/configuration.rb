module Houston::Scheduler
  class Configuration
    
    def initialize
      @use_planning_poker = true
      @use_mixer = true
      instance_eval(&Houston.config.module(:scheduler).config)
    end
    
    def planning_poker(arg)
      @use_planning_poker = false if arg == :off
    end
    
    def mixer(arg)
      @use_mixer = false if arg == :off
    end
    
    def use_planning_poker?
      @use_planning_poker
    end
    
    def use_mixer?
      @use_mixer
    end
    
  end
end
