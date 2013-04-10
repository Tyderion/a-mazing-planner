class window.Game
  constructor: (width, height, context) ->
    @width = width
    @height = height
    @context = context
    @grid = #[][]
    @timeout = 0
    @grid = for row in [0..height]
      	for col in [0..width]
          0#if Math.random() > 0.3 then 0 else 1
    @createhandlers()
    @redrawContext()


  redrawContext:  =>
    console.log "Redrawing Context!"
    $("canvas").clearCanvas()
    @checkDims()
    steps = @width/window.gridsize
    @context.canvas.width  = @width;
    @context.canvas.height = @height;
    @drawGrid(0,0, steps)
    @timeout = 0

  checkDims: ->
    @width = window.innerWidth if @width != window.innerWidth
    @height = window.innerHeight if @height != window.innerheight



  click: (event) ->
    x = Math.floor event.clientX / window.gridsize
    y = Math.floor event.clientY / window.gridsize
    current = @grid[x][y]
    if current == 0 or current == 1
      newval = @grid[x][y]*-1 +1 #Swap 0 and 1
      if @grid[x+1][y] == @grid[x][y+1] == @grid[x+1][y+1] == current
        for i in [x..x+1]
          for j in [y..y+1]
            @grid[i][j] = newval
      # @grid[x][y] = newval
      @redrawContext()

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
        @timeout = window.setTimeout(@redrawContext, 20) if @timeout <= 0

      "mousewheel": (e, delta, deltaX, deltaY) =>
        # Maybe use timeout too ... or something that just waits until user stops or just updates every second
        if deltaY > 0
          window.gridsize += 1 if window.gridsize < 40
        else
          window.gridsize -= 1 if window.gridsize > 5
        if @timeout <= 0
          @timeout = window.setTimeout(@redrawContext, 20)
