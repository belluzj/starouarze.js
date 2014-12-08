Template.Home.events
  'click .btn-create': ->
    Router.go '/create'
  'click .btn-join': ->
    Router.go '/join'

Template.CreateRound.helpers
  'proposedName': ->
    # TODO generate cool random names
    'mfdskqfjkmfqsjk'

Template.CreateRound.events
  'click .btn-start': (event, template) ->
    Meteor.call 'createRound', {
      name: template.$('input[name="round-name"]').val()
      nb_users: template.$('input[name="nb-players"]').val() | 0
    }, (error) ->
      if error
        console.log(error)
      else
        Router.go '/join'

Template.JoinRound.helpers
  'openRounds': ->
    Rounds.find {missing_users: {$gt: 0}}
  'canLeave': ->
    @_id == Meteor.user().round_id
  'canJoin': ->
    not Meteor.user().round_id

Template.JoinRound.events
  'click .round-join': (event, template) ->
    Meteor.call 'joinRound', @_id
  'click .round-leave': (event, template) ->
    Meteor.call 'leaveRound'

Tracker.autorun ->
  if Meteor.user()
    round = Rounds.findOne Meteor.user().round_id
    if round?.missing_users == 0
      #FIXME fix me please
      Router.go '/loading'



