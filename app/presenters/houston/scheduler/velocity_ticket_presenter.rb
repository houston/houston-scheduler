class Houston::Scheduler::VelocityTicketPresenter < TicketPresenter
  
  def ticket_to_json(ticket)
    project = ticket.project
    { projectTitle: project.name,
      projectColor: project.color,
      number: ticket.number,
      estimated: ticket.effort,
      actual: ticket.commit_time }
  end
  
end
