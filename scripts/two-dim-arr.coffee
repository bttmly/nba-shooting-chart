  class TwoDimensionalArray extends Array
    constructor : ( dim1size, dim2size, value = "" ) ->
      if ( oArr = dim1size ) instanceof Array
        passThru = true

      if passThru
        d1 = arr.length
        d2 = arr[0].length
      else
        d1 = dim1size
        d2 = dim2size
        
      for i in [ 0...d1 ]
        arr = []
        for j in [ 0...d2 ]
          arr.push do ->
            if passThru
              return oArr[i][j]
            if typeof value is "function"
              return value( i, j )
            else 
              return value
        this.push arr

    # Unlike vanilla Arrays, forEach is chainable.
    # Callback receives ( currentItem, rowIndex, columnIndex, 2dArray )
    forEach : ( callback ) ->
      for row, i in this
        for item, j in this[0]
          callback( item, i, j, this )
      return this

    # An alias to forEach
    each : ->
      return this.forEach( arguments )

    # Callback receives ( currentItem, rowIndex, columnIndex, 2dArray )
    map : ( callback ) ->
      map = new TwoDimensionalArray( this.length, this[0].length )
      for row, i in this
        for item, j in row
          map[i][j] = callback( item, i, j, this )
      return map

  this.TwoDimensionalArray = TwoDimensionalArray