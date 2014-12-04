Router.configure
  layoutTemplate: 'ApplicationLayout'

Router.onBeforeAction ->
  if not Meteor.user()
    @render 'Login'
  else
    @next()

Router.route '/', ->
  @render 'Home'

Router.route '/create', ->
  Meteor.call 'leaveRound'
  @render 'CreateRound'

Router.route '/join',
  action: ->
    @render 'JoinRound'
  subscriptions: ->
    @subscribe 'openRounds'

Router.route '/play',
  action: ->
    @render 'GameUI'
  subscriptions: ->
    [
      @subscribe 'scenegraph'
      @subscribe 'currentRound'
    ]

