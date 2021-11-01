-- if you're missing a global, throw it in here.
-- this is called at the end of init()
-- and some globals disappear when the metatable is created.
-- pretty weird. this is a hack for sure.
return {
  -- single-letter stuff might be cool
  -- but I'd like to see it more tightly coupled to the REPL here cos:
  -- - other short commands use this API; may feel inconsistent
  -- - e.g. might have other "modes" where l means something else
  l=l,
  
  -- this is a great global for debugging
  -- but I almost prefer to use its full name
  -- for visibility & script-to-script consistency (expectations)
  tu=tu,

  -- similar - I think some of the stuff in here will be good for debugging
  -- but so much of the REPL & SC stuff is 
  fn=fn,
  
  -- I think this is only needed here cos it uses self
  -- might be the case for some of these others
  -- I usually write modules assuming a singleton "service"
  graphics=graphics,
  clocks=clocks,
  loess=loess,
  network=network,
  metadata=metadata,
  state=state,
  json=json,
  history=history,

  -- sounds real specific - maybe a method/function of `network` global?
  -- e.g. network.get_status?
  get_network_status=get_network_status,
}
