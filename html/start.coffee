$ ->
  drawingCanvas = document.getElementById "drawing"

  # Check the element is in the DOM and the browser supports canvas
  if drawingCanvas.getContext
    $('p').remove()
    # Initaliase a 2-dimensional drawing context
    context = drawingCanvas.getContext('2d');
    $(window).on "resize", (event) ->
      redrawContext(context)

    $(window).on "mousewheel", (event, delta, deltaX, deltaY) ->
      if deltaY > 0
        window.gridsize += deltaY if window.gridsize < 40
      else
        window.gridsize += deltaY if window.gridsize > 5
      redrawContext(context)


    width = window.innerWidth
    height = window.innerHeight

    context.canvas.width  = width;
    context.canvas.height = height;
    $("canvas").drawArc
      fillStyle: "black"
      x: 100
      y: 100
      radius: 50

    #Canvas commands go here
    window.gridsize = 19
    steps = width/window.gridsize
    drawGrid(0,0, width, height, steps)

redrawContext = (context) ->
    # Initaliase a 2-dimensional drawing context


    $("canvas").clearCanvas()
    width = window.innerWidth
    height = window.innerHeight
    steps = width/window.gridsize
    context.canvas.width  = width;
    context.canvas.height = height;
    drawGrid(0,0, width, height, steps)

checkDims = ->
  global height,width
  width = window.innerWidth if width != window.innerWidth
  height = window.innerHeight if height != window.innerheight

drawGrid = (x, y, width, height, steps) ->
  vertsteps = (height/width)*steps
  $('canvas').drawRect
    layer: true
    name: "border"
    group: "grid"
    strokeStyle: "#000",
    strokeWidth: 2
    x: x, y: y,
    width: width,
    height: height,
    fromCenter: false
  i = 0

  while (i < width)
    $("canvas").drawLine
      layer: true
      name: "vline#{i}"
      group: "grid"
      strokeStyle: "#B0B0B0" ,
      strokeWidth: 1,
      x1: i, y1: 0,
      x2: i, y2: height
    i += (width/steps)

  j = 0

  while (j < height)
    $("canvas").drawLine
      layer: true
      name: "hline#{j}"
      group: "grid"
      strokeStyle: "#B0B0B0" ,
      strokeWidth: 1,
      x1: 0, y1: j,
      x2: width, y2: j
    j += height/vertsteps



