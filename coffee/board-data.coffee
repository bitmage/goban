define ->
  Board = ->
    board = []
    board[x] = [] for x in [1..19]

    board.get = (coord) ->
      [x,y] = coord
      board[x]?[y]

    board.set = (coord, stone) ->
      [x,y] = coord
      board[x]?[y] = stone

    return board

  Board.offBoard = (coord) ->
    for n in coord
      return true if n not in [1..19]
    return false

  Board.switchColor = (color) ->
    if color is 'black' then 'white' else 'black'

  Board.compareCoord = (coordA, coordB) ->
    _.isEqual coordA, coordB

  Board.unionCoord = (coordsA, coordsB) ->
    newCoords = _.clone coordsA

    exists = (b) ->
      _.any coordsA, (a) -> _.isEqual a, b

    _.each coordsB, (b) ->
      newCoords.push b unless exists(b)

    return newCoords

  return Board
