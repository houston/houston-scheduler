class Houston::Scheduler::TicketPresenter < TicketPresenter
  include MarkdownHelper

  def ticket_to_json(ticket)
    reporter = ticket.reporter
    super.merge(
      description: mdown(ticket.description),
      tasks: ticket.tasks.map { |task| task.ticket = ticket; {
        id: task.id,
        description: task.description,
        number: task.number,
        letter: task.letter,
        effort: task.effort } },
      reporter: reporter && {
        email: reporter.email,
        name: reporter.name },
      milestoneId: ticket.milestone_id,
      milestoneName: ticket.milestone.try(:name),
      resolved: ticket.resolved?,
      prerequisites: ticket.prerequisites)
  end

end
