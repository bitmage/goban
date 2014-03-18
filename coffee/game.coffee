## Game State/Logic
define ['js/board-data'],
  (Board) ->

    return ->

      # GAME STATE

      state =
        groups: []
        history: []
        prisoners:
          white: 0
          black: 0
        nextMove: 'black'
        board: Board()

      {groups, history, prisoners, board} = state

      # PRIVATE HELPERS

      # is position valid stone or empty space?
      valid = (coord, shouldBeEmpty=true) ->
        return false if Board.offBoard(coord)
        return shouldBeEmpty == not (board.get coord)?

      # find neighboring stones or empty spaces
      neighbors = (coord, empty=true) ->
        nbs = []
        [x, y] = coord
        for coord in [ [x, y-1], [x+1, y], [x, y+1], [x-1, y] ]
          if valid coord, empty
            nbs.push (if empty then coord else board.get coord)
        return nbs

      # remove the stone at a given coordinate
      removeStone = (coord) =>
        @onRemoveStone coord
        board.set coord, undefined

      suicide = (color, coord) ->
        # not suicide if there are nearby liberties
        if neighbors(coord, true).length > 0
          return false

        # not suicide if any connected friendly groups have more than 1 liberty
        for neighbor in neighbors coord, false
          if neighbor.color == color
            if groups[neighbor.groupNum].liberties() > 1
              return false
          else

            # or if you can kill something
            if groups[neighbor.groupNum].liberties() == 1
              return false

        # suicide
        return true

      playable = (color, coord) ->
        return false unless color = state.nextMove
        return false if not valid(coord)
        return false if suicide(color, coord)

        if history.length > 0
          last = history[history.length - 1]
          if last.ko and last.ko[0] == coord[0] and last.ko[1] == coord[1]
            return false
        return true

      Group = (color, coord) ->
        group = [coord]
        group.color = color
        group.num = groups.length

        #test to see if a group has liberties
        group.liberties = ->
          liberties = []
          for stone in this
            #count unique liberties
            liberties = Board.unionCoord liberties, neighbors(stone)
          return liberties.length

        group.test = =>
          if group.liberties() == 0
            for stone in group
              removeStone stone
            prisoners[color] += group.length
            delete groups[group.num]
            return false

          else
            return true

        return group

      place = (color, coord) =>

        if playable(color, coord)
          [x, y] = coord

          #add this stone to the board
          board.set coord, {
            color: color
            groupNum: groups.length
          }

          @onAddStone(color, coord)

          #create history record
          record =
            color: color
            x: x
            y: y

          group = Group(color, coord)

          for neighbor in neighbors coord, false

            #if they're friendly, add them to this group and recalculate liberties
            if neighbor.color == color

              ngNum = neighbor.groupNum
              if group.num != ngNum
                ng = groups[ngNum]

                #update the group for neighbor stones
                for n in ng
                  board.get(n).groupNum = groups.length

                group.push ng...
                delete groups[ngNum]

            #if they're enemies, calculate their liberties and remove them if they have none
            else
              foe = groups[neighbor.groupNum]

              # sometimes we double kill due to multiple neighbor
              # stones from the same group - just ignore if 'foe' is undefined
              if foe?.test() == false
                record.kills = foe
                record.ko = foe[0] if foe.length == 1

          groups.push group
          history.push record

          state.nextMove = Board.switchColor(state.nextMove)

      #  ---------------------------------------------------------------
      # PUBLIC INTERFACE
      #  ---------------------------------------------------------------
      @onRemoveStone = ->
      @onAddStone = ->
      @playerMove = (color, coord) ->
        place(color, coord)

      @onValidatedMove = ->
      @checkValidMove = (color, coord) ->
        if playable(color, coord)
          @onValidatedMove coord
          return true
        else
          @onValidatedMove [-1, -1]
          return false

      @getState = ->
        _.clone state

      # manual bindAll, since lodash isn't cooperating
      for own prop of @
        @[prop] = @[prop].bind(@)

      return @
      #  ---------------------------------------------------------------
