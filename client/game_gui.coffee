
class Laser
 
    constructor: (position, rotation, @speed, @color) ->
        @length = 30
        @remainingFrames = 50
        
        #FIXME - length/2 on the other side and other cases 
        @mesh = BB.Mesh.CreateCylinder("laser", @length, 1, 1, 6, 1, BB.scene)
        @mesh.position.x = position.x
        @mesh.position.y = position.y
        @mesh.position.z = position.z + length/2
        @mesh.rotation.x = rotation.x + Math.atan(1)*2
        @mesh.rotation.y = rotation.y
        @mesh.rotation.z = rotation.z
        
        
        @move()
        
    #FIXME update position according to actual dynamics 
    move: ->
      console.log('move')
      @mesh.position.z += @speed
      if(@remainingFrames-- > 0)
        setTimeout (@move.bind @), 20
      else
        @mesh.dispose()
        delete @
    

Template.GameUI.rendered = ->
  $(window).on 'keydown', (event) ->
    switch event.which
      when KeyCodes.LEFT_ARROW
        BB.cube.mesh.position.x -= 20
      when KeyCodes.RIGHT_ARROW
        BB.cube.mesh.position.x += 20
      when KeyCodes.UP_ARROW
        BB.cube.mesh.position.y += 20
      when KeyCodes.DOWN_ARROW
        BB.cube.mesh.position.y -= 20
      when KeyCodes.SPACE
        BB.cube.mesh.material.diffuseColor.r = 1
    scenegraph.get().update BB.cube
  $(window).click ->
    fire = new Laser(BB.cube.mesh.position, BB.cube.mesh.rotation, 40, "default_laser")
    
    
Template.GameUI.created = ->
  
  $(window).bind("contextmenu", (e) ->  
	  false;  
  )
  
  $( "#gui" ).mousemove (event) ->
    $( "#viseur_out" ).offset({top: event.pageY - 8, left: event.pageX - 7})
    angle = 90 + 57.3 * Math.atan2(event.pageY - $( "#gui" ).height()/2, event.pageX - $( "#gui" ).width()/2)
    $( "#viseur_out" ).css({transform: 'rotate(' + angle + 'deg)'})
    
Template.GameUI.helpers
  lifePercent: ->
    Meteor.user().life or 0
  
Template.GameLoading.helpers
  loadingGlobal: ->
    round = Rounds.findOne Meteor.user().round_id
    round.loading or 0
  loadindTxt: ->
    "loading please wait until it is loaded"