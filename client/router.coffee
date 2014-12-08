Router.configure
  layoutTemplate: 'MenuLayout'

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
  layoutTemplate: 'GameLayout'
  action: ->
    Session.set('inGame', true)
    @render 'GameUI'
  subscriptions: ->
    @subscribe 'currentRound'

