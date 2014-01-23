_.extend Backbone.Collection.prototype,

  getBackboneClass : ->
    return "Collection"

  pluckUnique : ( attr ) ->
    return _.uniq this.pluck( attr )

  collectionFilter : ->
    constructor = Object.getPrototypeOf( this ).constructor
    args = Array.prototype.slice.call( arguments )
    args.unshift( this.models )

    return new constructor( _.filter.apply( _, args ) )

  collectionDynamicFilter : ( filterArray ) ->
    constructor = Object.getPrototypeOf( this ).constructor
    # args = Array.prototype.slice.call( arguments )

    comparators = [">", "greaterThan", "<", "lessThan", ">=", "greaterThanOrEqual", "<=", "lessThanOrEqual", "===", "equalTo", "is", "!==", "notEqualTo", "isnt"]
    test = ( post, comparator, value ) ->
      switch comparator
        when ">" or "greaterThan"
          return post > value
        when "<" or "lessThan"
          return post < value
        when ">=" or "greaterThanOrEqual"
          return post >= value
        when "<=" or "lessThanOrEqual"
          return post <= value
        when "===" or "equalTo" or "is"
          return post is value
        when "!==" or "notEqualTo" or "isnt"
          return post isnt value

    results = this.toJSON()
    for filterObj in filterArray
      console.log results.length
      results = results.filter ( obj ) ->
        return test( obj[ filterObj.prop ], filterObj.comparator, filterObj.value )

    console.log results.length

    return new constructor( results )

_.extend Backbone.Model.prototype,

  getBackboneClass : ->
    return "Model"

_.extend Backbone.View.prototype,

  getBackboneClass : ->
    return "View"