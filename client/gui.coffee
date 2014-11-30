Template.Home.events
  'click .btn-create': ->
    Router.go '/create'
  'click .btn-join': ->
    Router.go '/join'

Template.CreateRound.helpers
  'proposed-name': ->
    # TODO generate cool random names
    'mfdskqfjkmfqsjk'
