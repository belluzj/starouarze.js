# The main library export
@SG = SG = {}

# Other internal namespaces and objects
@Internals = Internals = {}

# TODO sanitized version for meteor to send back to clients
class SG.Error extends Error
  constructor: (message, cause) ->
    @name = 'SceneGraph Error'
    @message = message
    if cause
      @cause = cause
      @message += " (cause: #{ cause.message })"
