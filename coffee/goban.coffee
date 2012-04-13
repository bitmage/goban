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

  gb =
    whiteStone: (x, y) ->
      xPos = x * xint - xint / 2
      yPos = y * yint - yint / 2
      gradCol = new paper.GradientColor yGrad, [xPos - xint * 0.5, yPos + yint * 0.5], [xPos, yPos]
      Circ xPos, yPos, xint / 2.4, null, gradCol

    blackStone: (x, y) ->
      xPos = x * xint - xint / 2
      yPos = y * yint - yint / 2
      gradCol = new paper.GradientColor bGrad, [xPos + xint * 0.5, yPos - yint * 0.5], [xPos, yPos]
      Circ xPos, yPos, xint / 2.4, null, gradCol

window.onload = ->
  canvas = document.getElementById("goban")
  paper.setup canvas

  gb = GoBoard canvas
  gb.blackStone 4, 4
  gb.whiteStone 16, 16
  gb.blackStone 3, 16
  gb.whiteStone 16, 3

  paper.view.draw()
