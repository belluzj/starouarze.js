
@BB = BB = BABYLON

# Reactive members
reactiveProperties =
  # The engine for the main scene
  engine: null
  # The game scene
  scene: null

for own name, val of reactiveProperties
  do ->
    reactive = new ReactiveVar val
    Object.defineProperty BB, name,
      get: -> reactive.get()
      set: (val) -> reactive.set(val)

  
