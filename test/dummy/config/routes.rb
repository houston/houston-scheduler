Rails.application.routes.draw do

  mount Houston::Scheduler::Engine => "/houston-scheduler"
end
