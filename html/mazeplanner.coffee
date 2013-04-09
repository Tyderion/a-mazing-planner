class window.Game
  constructor: (width, height, context) ->
    @width = width
    @height = height
    @context = context
    @grid = #[][]
      for row in [0..height]
      	for col in [0..width]
          if Math.random() > 0.3 then 0 else 1
    @createhandlers()
    @redrawContext()


  redrawContext:  ->

    $("canvas").clearCanvas()
    @checkDims()
    steps = @width/window.gridsize
    @context.canvas.width  = @width;
    @context.canvas.height = @height;
    @drawGrid(0,0, steps)

  checkDims: ->
    @width = window.innerWidth if @width != window.innerWidth
    @height = window.innerHeight if @height != window.innerheight


  click: (event) ->
    console.log event

  drawGrid: (x, y, steps) ->
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


    start = 0#window.gridsize/2
    for x in [0..steps]
      for y in [0..vertsteps]
        if @grid[x][y] == 1
          $("canvas").drawRect
            fillStyle: "#000"
            x: start+x*gridsize
            y: start+y*gridsize
            width: gridsize
            height: gridsize
            fromCenter: false
        else if @grid[x][y] == 2
          $("canvas").drawRect
            fillStyle: "#686868"
            x: start+x*gridsize
            y: start+y*gridsize
            width: gridsize
            height: gridsize
            fromCenter: false

  createhandlers: ->
    $(window).on
      'click': (e) =>
        @click(e)
      "resize": (e) =>
        # Use Timeout....
        @redrawContext()
      "mousewheel": (e, delta, deltaX, deltaY) =>
        # Maybe use timeout too ... or something that just waits until user stops or just updates every second
        if deltaY > 0
          window.gridsize += deltaY if window.gridsize < 40
        else
          window.gridsize += deltaY if window.gridsize > 5
        @redrawContext()

