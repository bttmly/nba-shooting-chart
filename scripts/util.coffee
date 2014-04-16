window.App or= {}

# adapted from http://valschuman.blogspot.com/2012/08/javascript-camelcase-function.html
camelize = ( str ) ->
    str = str.replace( /([^a-zA-Z0-9_\- ])|^[_0-9]+/g, "" ).trim().toLowerCase();
    str = str.replace /([_-]+)([a-zA-Z0-9])/g, ( a, b, c ) ->
        return c.toUpperCase()

collectify = ( headers, arrays ) ->
  _.object( headers, array ) for array in arrays

cleanPropNames = ( obj ) ->
  ret = {}
  for key, val of obj
    ret[ camelize( key ) ] = val
  return ret

prototypeChain = ( obj ) ->
  chain = []
  while ( obj = Object.getPrototypeOf( obj ) )
    chain.push( obj )
  return chain

App.util = 
  camelize : camelize
  collectify : collectify
  cleanPropNames : cleanPropNames
  prototypeChain : prototypeChain

