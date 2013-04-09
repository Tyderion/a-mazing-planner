width = 100
height = 100
class window.Game
  constructor: (width, height, context) ->
    @width = width
    @height = height
    @context = context
    @grid = for row in [0..height]
    	for col in [0..width]
                0
    console.log this
    @redrawContext()


  redrawContext:  ->
    # Initaliase a 2-dimensional drawing context
    console.log "redrawContext"
    $("canvas").clearCanvas()
    @checkDims()
    steps = @width/window.gridsize
    @context.canvas.width  = @width;
    @context.canvas.height = @height;
    @drawGrid(0,0, steps)

  checkDims: ->
    @width = window.innerWidth if width != window.innerWidth
    @height = window.innerHeight if height != window.innerheight

  drawGrid: (x, y, steps) ->
    console.log "Drawing grid"
    vertsteps = (@height/@width)*steps
    $('canvas').drawRect
      layer: true
      name: "border"
      group: "grid"
      strokeStyle: "#000",
      strokeWidth: 2
      x: x, y: y,
      width: @width,
      height: @height,
      fromCenter: false
    i = 0
    console.log "Widht: #{@width} and height: #{@height}"
    while (i < @width)
      $("canvas").drawLine
        layer: true
        name: "vline#{i}"
        group: "grid"
        strokeStyle: "#B0B0B0" ,
        strokeWidth: 1,
        x1: i, y1: 0,
        x2: i, y2: @height
      i += (@width/steps)

    j = 0

    while (j < @height)
      $("canvas").drawLine
        layer: true
        name: "hline#{j}"
        group: "grid"
        strokeStyle: "#B0B0B0" ,
        strokeWidth: 1,
        x1: 0, y1: j,
        x2: @width, y2: j
      j += @height/vertsteps

