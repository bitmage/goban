Object.extend()

Circ = (x, y, radius, line, fill, width) ->
  circ = new paper.Path.Circle(new paper.Point(x, y), radius)
  circ.radius = radius
  circ.x = x
  circ.y = y
  circ.strokeColor = line if line?
  circ.strokeWidth = width if width?
  circ.fillColor = fill if fill?
  return circ

Line = (start, end) ->
  line = new paper.Path()
  line.strokeColor = 'black'
  line.add new paper.Point start
  line.add new paper.Point end
  return line


GoBoard = (canvas) ->

  xint = canvas.width / 19
  yint = canvas.height / 19

  for x in [(xint / 2)..canvas.width] by xint
    Line [x, yint / 2], [x, canvas.height - yint / 2]

  for y in [(yint / 2)..canvas.width] by yint
    Line [xint / 2, y], [canvas.height - xint / 2, y]

  for x in [(xint / 2 + xint * 3)..canvas.width] by xint * 6
    for y in [(yint / 2 + yint * 3)..canvas.height] by yint * 6
      Circ x, y, 3, 'black', 'black'

  bGrad = new paper.Gradient [['gray', 0.0], ['black', 1]], 'radial'
  yGrad = new paper.Gradient [['gray', 0.0], ['white', 1]], 'radial'

  getPos = (coords) ->
    [x, y] = coords
    xPos = x * xint - xint / 2
    yPos = y * yint - yint / 2
    [xPos, yPos]

  whiteStone = (x, y) ->
    [xPos, yPos] = getPos [x, y]
    gradCol = new paper.GradientColor yGrad, [xPos - xint * 0.5, yPos + yint * 0.5], [xPos, yPos]
    Circ xPos, yPos, xint / 2.4, null, gradCol

  blackStone = (x, y) ->
    [xPos, yPos] = getPos [x, y]
    gradCol = new paper.GradientColor bGrad, [xPos + xint * 0.5, yPos - yint * 0.5], [xPos, yPos]
    Circ xPos, yPos, xint / 2.4, null, gradCol

  groups = []
  history = []

  #board state
  board = ([] for x in [0..18] )
  board.get = (coord=[]) ->
    [x, y] = coord
    if board[x]?
      return board[x][y]
    else
      return undefined
  board.remove = (coord) ->
    [x, y] = coord
    (@get coord).graphic.remove()
    return delete board[x][y]

  #is position valid stone or empty space
  valid = (pos, shouldBeEmpty=true) ->
    offBoard = (n) -> n not in [1..19]
    return false if offBoard(pos[0]) or offBoard(pos[1])
    return shouldBeEmpty == not (board.get pos)?

  #find neighboring stones or empty spaces
  neighbors = (pos, empty=true) ->
    nbs = []
    [x, y] = pos
    for pos in [ [x, y-1], [x+1, y], [x, y+1], [x-1, y] ]
      if valid pos, empty
        nbs.push (if empty then pos else board.get pos)
    return nbs

  prisoners =
    white: 0
    black: 0

  # interface to control the board
  gb =
    history: history
    whiteStone: whiteStone
    blackStone: blackStone
    prisoners: prisoners

    getPos: getPos

    findIntersection: (coords) ->
      [x, y] = coords
      snap = (coord, interval) -> Math.floor (coord / interval + 1)
      [snap(x, xint), snap(y, yint)]

    nextMove:
      suicide: ->
        #not suicide if there are nearby liberties
        for neighbor in neighbors @position, true
          return false

        #not suicide if any connected friendly groups have more than 1 liberty
        for neighbor in neighbors @position, false
          if neighbor.color == @color
            if groups[neighbor.groupNum].liberties() > 1
              return false
          else
            #or if you can kill something
            if groups[neighbor.groupNum].liberties() == 1
              return false

        #suicide
        return true

      playable: ->
        return false if not valid @position
        return false if @suicide()
        if history.length > 0
          last = history[history.length - 1]
          if last.ko and last.ko[0] == @position[0] and last.ko[1] == @position[1]
            return false
        return true

      graphic: blackStone(-1, -1)
      position: null
      color: 'black'
      hover: (pos) ->
        @position = gb.findIntersection pos
        if not @playable()
          @position = [-1, -1]

        @graphic.position = gb.getPos @position

      place: ->
        if @playable()
          [x, y] = @position

          #add this stone to the board
          board[x][y] =
            color: @color
            groupNum: groups.length
            graphic: @graphic

          #create history record
          record =
            color: @color
            x: x
            y: y

          group = [@position]
          group.color = @color
          group.num = groups.length

          #test to see if a group has liberties
          group.liberties = ->
            liberties = []
            for stone in this
              #count unique liberties
              liberties = liberties.union neighbors stone
            return liberties.length

          group.test = ->
            if @liberties() == 0
              for stone in this
                board.remove stone
              prisoners[@color] += this.length
              delete groups[group.num]
              return false

            else
              return true

          for neighbor in neighbors @position, false

            #if they're friendly, add them to this group and recalculate liberties
            if neighbor.color == @color

              ngNum = neighbor.groupNum
              if group.num != ngNum
                ng = groups[ngNum]

                #update the group for neighbor stones
                for n in ng
                  board.get(n).groupNum = groups.length

                group.push ng...
                status = delete groups[ngNum]

            #if they're enemies, calculate their liberties and remove them if they have none
            else
              foe = groups[neighbor.groupNum]
              if foe.test() == false
                record.kills = foe
                record.ko = foe[0] if foe.length == 1

          groups.push group
          group.test()

          history.push record

          if @color == 'white'
            @color = 'black'
            @graphic = blackStone -1, -1
          else
            @color = 'white'
            @graphic = whiteStone -1, -1

          #console.log 'board: ', board
          #console.log 'groups: ', groups
          #console.log 'history: ', history

          return this

window.onload = ->
  canvas = document.getElementById("goban")
  paper.setup canvas

  gb = GoBoard canvas

  tool = new paper.Tool()

  tool.onMouseMove = (event) ->
    if event.event.target == canvas
      gb.nextMove.hover [event.event.offsetX, event.event.offsetY]
    else
      gb.nextMove.hover gb.getPos [-1, -1]

  tool.onMouseDown = (event) ->
    gb.nextMove.place()

  paper.view.draw()
