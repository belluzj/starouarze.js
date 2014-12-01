class Round
  constructor: (round) ->
    @name = round.name or "<no name>"
    @nb_users = round.nb_users or "2"
    @users = round.users or []

  cur_nb_users: ->
    @users.length()
