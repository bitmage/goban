require ['js/board-ui', 'js/game'],
  (BoardUI, GameEngine) ->

    ## Widget Interface
    GoBoard = (canvas) ->

      # initialize UI and Game engine
      ui = new BoardUI(canvas)
      game = new GameEngine()

      ui.onHover = game.checkValidMove
      game.onValidatedMove = ui.hoverStone

      ui.onPlayerMove = game.playerMove
      game.onAddStone = ui.addStone
      game.onRemoveStone = ui.removeStone

      # test ko
      #game.playerMove 'black', [3,4]
      #game.playerMove 'white', [3,5]
      #game.playerMove 'black', [4,5]
      #game.playerMove 'white', [4,4]
      #game.playerMove 'black', [5,4]
      #game.playerMove 'white', [5,5]
      #game.playerMove 'black', [4,3]
      #game.playerMove 'white', [4,6]
      #game.playerMove 'black', [5,6]

      # test throw-in
      #game.playerMove 'black', [4,4]
      #game.playerMove 'white', [4,3]
      #game.playerMove 'black', [5,4]
      #game.playerMove 'white', [5,3]
      #game.playerMove 'black', [4,5]
      #game.playerMove 'white', [3,4]
      #game.playerMove 'black', [5,6]
      #game.playerMove 'white', [3,5]
      #game.playerMove 'black', [6,5]
      #game.playerMove 'white', [4,6]
      #game.playerMove 'black', [5,7]
      #game.playerMove 'white', [6,4]
      #game.playerMove 'black', [3,6]

      #console.log '5,5 valid:', game.checkValidMove('white', [5,5])

      #console.log game.getState()

      #_on ui, 'onHover', game.checkValidMove
      #_on game, 'onValidatedMove', ui.hoverStone

      #_on ui, 'onPlayerMove', game.playerMove
      #_on game, 'onAddStone', ui.addStone
      #_on game, 'onRemoveStone', ui.removeStone

    window.onload = ->
      canvas = document.getElementById("goban")

      gb = new GoBoard(canvas)

      #gb = new BoardUI(canvas)

      #gb.addStone('black', [3, 4])
      #gb.addStone('white', [17, 16])
      #gb.addStone('black', [16, 3])
      #setTimeout (->
        #gb.removeStone([3, 4])
        #gb.removeStone([17, 16])
      #), 2000

      #gb.onHover = gb.hoverStone
      #gb.onPlayerMove = gb.addStone
