
Template.GameUI.rendered = ->
  $(window).on 'keydown', (event) ->
    console.log(event)
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