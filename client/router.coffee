

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
  @render 'CreateRound'

Router.route '/join', ->
  @render 'JoinRound'
