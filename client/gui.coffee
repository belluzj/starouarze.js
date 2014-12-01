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
    Rounds.insert
      users: [Meteor.userId()]
      name: template.$('input[name="round-name"]').val()
      nb_users: template.$('input[name="nb-players"]').val() | 0
    Router.go '/join'

Template.JoinRound.helpers
  'openRounds': ->
    Rounds.find {missingUsers: {$gt: 0}}
  'userId': ->
    Meteor.userId()


