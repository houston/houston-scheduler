class Houston::Scheduler::TicketPresenter < FullTicketPresenter
  
  def ticket_to_json(ticket)
    super.merge(
      milestoneId: ticket.milestone_id,
      milestoneName: ticket.milestone.try(:name),
      sprintId: ticket.sprint_id,
      resolved: ticket.resolved?,
      prerequisites: ticket.prerequisites)
  end
  
end
