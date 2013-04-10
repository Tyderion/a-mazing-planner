class window.Game
  constructor: (width, height, context) ->
    @width = width
    @height = height
    @context = context
    @grid = #[][]
    @test = []
    @timeout = 0
    @counter = 0
    @grid = for row in [0..height]
      	for col in [0..width]
          0#if Math.random() > 0.3 then 0 else 1
    @createhandlers()
    @redrawContext()


  debug: ->
    for i in [0..8]
      for j in [0..8]
        @string = "#{@string} #{@grid[j][i]}"
      @string = "#{@string} \n"
    @string = "#{@string} \n\n"

  redrawContext:  =>
    # console.log "Redrawing Context!"
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



  # Return true if the block at x,y is or can be the topleft cell of a tower
  checkValidity: (x,y) =>
    # If its outside, it is not valid xD
    return false if (x< 0 or y < 0 or x > @width or y > @height)
    index = x*@width+y
    # If we already calculated the value, just return this one
    unless @test[index]  is undefined
      return @test[index]
    current = @grid[x][y]
    # If all 4 are empty, tower can be placed
    if @grid[x+1][y] == @grid[x][y+1] == @grid[x+1][y+1] == current
      if current == 0
        @test[index] = true
      else
        # Testing left, top and 1 diagonal seems to suffice, if I test both horizontals, it does not work xD
        if @checkValidity(x-1, y) or @checkValidity(x, y-1) or @checkValidity(x-1, y-1)
          @test[index] = false
        @test[index] = true if @test[index] is undefined
    else
     @test[index] = false
    return @test[index]

  click: (event) ->
    @test = []
    @counter = 0
    x = Math.floor( event.clientX / window.gridsize)
    y = Math.floor( event.clientY / window.gridsize)

    current = @grid[x][y]
    if current <= 2
      newval = @grid[x][y]*-1 +1 #Swap 0 and 1
      if @checkValidity(x,y)
        for i in [x..x+1]
          for j in [y..y+1]
            @grid[i][j] = newval
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
        # if deltaY > 0
        #   window.gridsize += 1 if window.gridsize < 40
        # else
        #   window.gridsize -= 1 if window.gridsize > 5
        # if @timeout <= 0
        #   @timeout = window.setTimeout(@redrawContext, 20)
