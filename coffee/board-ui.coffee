## Board State/Logic
define ['js/board-data'],
  (Board) ->

    return (canvas) ->

      #  ---------------------------------------------------------------
      # initialize Paper.js
      #  ---------------------------------------------------------------

      paper.setup(canvas)
      tool = new paper.Tool()

      # lazy UI update, allow for multiple synchronous actions to occur
      updating = false
      updateUI = ->
        unless updating
          updating = true
          setTimeout (->
            updating = false
            paper.view.draw()
          ), 0

      # UI state
      state =
        stonesOnBoard: Board()
        placeHolder:
          black: null
          white: null
        currentColor: 'black'
        currentCoord: null

      # lazy hover, only send events if coords have changed
      compareCoord = (coordA, coordB) ->
        return false unless (Array.isArray(coordA) and Array.isArray(coordB))
        coordA[0] is coordB[0] and coordA[1] is coordB[1]

      updateCurrentCoord = (coord) ->
        if compareCoord(coord, state.currentCoord)
          return false

        else
          state.currentCoord = coord
          return true

      # set up basic objects

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

      # calculate board dimensions

      xint = canvas.width / 19
      yint = canvas.height / 19

      # draw guidelines and hoshi points

      for x in [(xint / 2)..canvas.width] by xint
        Line [x, yint / 2], [x, canvas.height - yint / 2]

      for y in [(yint / 2)..canvas.width] by yint
        Line [xint / 2, y], [canvas.height - xint / 2, y]

      for x in [(xint / 2 + xint * 3)..canvas.width] by xint * 6
        for y in [(yint / 2 + yint * 3)..canvas.height] by yint * 6
          Circ x, y, 3, 'black', 'black'

      stoneColor =
        black: new paper.Gradient [['gray', 0.0], ['black', 1]], 'radial'
        white: new paper.Gradient [['gray', 0.0], ['white', 1]], 'radial'

      # methods to convert between coordinates (19x19) and position (pixels)
      getStonePos = (coord) ->
        [x, y] = coord
        xPos = x * xint - xint / 2
        yPos = y * yint - yint / 2
        [xPos, yPos]

      getCoord = (pos) ->
        [x, y] = pos
        snap = (pos, interval) -> Math.floor (pos / interval + 1)
        [snap(x, xint), snap(y, yint)]

      renderStone = (color, coord) ->
        [xPos, yPos] = getStonePos coord
        gradCol = new paper.GradientColor stoneColor[color], [xPos - xint * 0.5, yPos + yint * 0.5], [xPos, yPos]
        stone = Circ(xPos, yPos, xint / 2.4, null, gradCol)

      #  ---------------------------------------------------------------
      #  PUBLIC INTERFACE
      #  ---------------------------------------------------------------
      @onHover = ->

      @hoverStone = (coord) ->
        state.placeHolder[state.currentColor].position = getStonePos(coord)


      @onPlayerMove = ->

      @addStone = (color, coord, isMove=true) ->

        stone = renderStone(color, coord)

        # remember the stone coord in case we need to remove it
        unless Board.offBoard(coord)
          state.stonesOnBoard.set coord, stone

        if isMove
          switchContext()

        updateUI()

      @removeStone = (coord) ->
        state.stonesOnBoard.get(coord).remove()
        state.stonesOnBoard.set coord, undefined
        updateUI()

      #  ---------------------------------------------------------------
      #  Complete Init
      #  ---------------------------------------------------------------

      switchContext = =>
        @hoverStone [-1, -1]
        state.currentColor = Board.switchColor(state.currentColor)

      # render placeholder stones
      for color of state.placeHolder
        state.placeHolder[color] = renderStone color, [-1, -1]

      # wire up events
      tool.onMouseMove = (event) =>
        if event.event.target == canvas
          coord = getCoord [event.event.offsetX, event.event.offsetY]

          if updateCurrentCoord coord
            @onHover state.currentColor, coord

        else
          if updateCurrentCoord [-1,-1]
            @hoverStone [-1, -1]

      tool.onMouseDown = (event) =>
        coord = getCoord [event.event.offsetX, event.event.offsetY]
        @onPlayerMove state.currentColor, coord

      updateUI()

      # manual bindAll, since lodash isn't cooperating
      for own prop of @
        @[prop] = @[prop].bind(@)

      return @
