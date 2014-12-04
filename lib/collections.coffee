# Persistent collections
@Rounds = new Mongo.Collection "rounds"

# In-memory collections
@Scenegraph = new Mongo.Collection "scenegraph", connection: null
