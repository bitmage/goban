define ->
  Board = ->
    board = []
    board[x] = [] for x in [1..19]

    board.get = (coord) ->
      [x,y] = coord
      console.log('should be array', board[x]) unless board[x]
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

  return Board
