#= require_tree ../../app/assets/javascripts/houston-scheduler/models/queuing_disciplines

# !nb: it'll take a little more work to load Backbone
# c.f. http://chaijs.com/api/assert/
#      http://visionmedia.github.com/mocha/
#      https://github.com/jfirebaugh/konacha
#      http://www.solitr.com/blog/2012/04/konacha-tutorial-javascript-testing-with-rails/

describe 'Queuing Disciplines', ->
  
  describe 'Maxamize ROI', ->
    
    before ->
      @qd = new Scheduler.QueuingDiscipline.MaximizeRoi()
    
    it 'should be able to report its own name', ->
      assert.equal(@qd.name, 'Maximize ROI')
