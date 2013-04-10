class window.Game
  @game
  @it: ->
    return @game



  constructor: (width, height, context, cellsX, cellsY, string) ->
    @width = width
    @height = height
    #TODO: Use cellsX/Y instead of width/height to generate grid (and other stuff) concerning the cells and not the pixels.
    @cellsX = cellsX
    @cellsY = cellsY
    @context = context
    @constructor.game = this
    @test = []
    @timeout = 0
    @counter = 0
    @string = string
    @grid = for row in [0..cellsX]
      	for col in [0..cellsY]
          0#if Math.random() > 0.3 then 0 else 1
    console.log @grid
    @createhandlers()
    #@load() if @string != ""
    @redrawContext()





  save: ->
    @createString()
    # console.log "Saving string as cookie!"
    $.cookie "test", @string,
      path: "/"
    console.log "Saved"

  load: ->
    @string = $.cookie('test')
    console.log "Loading: #{@string}"
    @readString()
    @string = ""
    @debug()
    console.log @string


  readString: ->
    @grid = for row in [0..cellsX]
        for col in [0..cellsY]
          0#if Math.random() >
    # for i in [0..@cellsX]
    #   for j in [0..@cellsY]
    #     if i*@cellsX+j >= @string.length
    #       @grid[i][j] = 0
    #     else
    #       @grid[i][j] = @string[i*@cellsX+j]

  createString: ->
    @string = ""
    for i in [0..@cellsX]
      for j in [0..@cellsY]
        @string += @grid[i][j]
    matches = @string.match(new RegExp('1', "g"))
    length = matches.length unless matches is null
    console.log "String representation has #{length} of 1s"

  debug: ->
    for i in [0..4]
      for j in [0..4]
        @string = "#{@string} #{@grid[j][i]}"
      @string = "#{@string} \n"
    @string = "#{@string} \n\n"

  redrawContext:  =>
    # console.log "Redrawing Context!"
    $("canvas").clearCanvas()
    @checkDims()
    @context.canvas.width  = @width;
    @context.canvas.height = @height;
    @drawGrid(0,0)
    @timeout = 0

  checkDims: ->
    @width = window.innerWidth if @width != window.innerWidth
    @height = window.innerHeight if @height != window.innerheight



  # Return true if the block at x,y is or can be the topleft cell of a tower
  checkValidity: (x,y) =>
    # If its outside, it is not valid xD
    return false if (x< 0 or y < 0 or x >= @cellsX or y >= @cellsY)
    index = x*@cellsX+y
    # If we already calculated the value, just return this one
    unless @test[index]  is undefined
      return @test[index]
    current = @grid[x][y]
    console.log "Current: #{current}"
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
    console.log "Coordinate (#{x},#{y}) is #{current} and is it valid to switch? #{@test[index]}"
    return @test[index]

  click: (event) ->
    @test = []
    @counter = 0
    x = Math.floor( event.clientX / window.gridsize)
    y = Math.floor( event.clientY / window.gridsize)
    # console.log "Coordinates: (#{event.clientX},#{event.clientY}) and cell: (#{x},#{y})"
    current = @grid[x][y]
    if current <= 2
      newval = @grid[x][y]*-1 +1 #Swap 0 and 1
      if @checkValidity(x,y)
        for i in [x..x+1]
          for j in [y..y+1]
            @grid[i][j] = newval
      @redrawContext()
    @save()


  drawGrid: (x,y) ->
    steps = @width/window.gridsize
    vertsteps = (@height/@width)*steps

    console.log "Steps: #{steps}"
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
    counter = 0
    while (i < @width)
      $("canvas").drawLine
        layer: true
        name: "vline#{i}"
        group: "grid"
        strokeStyle: "#B0B0B0" ,
        strokeWidth: 1,
        x1: i, y1: 0,
        x2: i, y2: @height
      counter++
      break if (counter > @cellsX)
      i += (@width/steps)


    j = 0
    counter = 0
    while (j < @height)
      $("canvas").drawLine
        layer: true
        name: "hline#{j}"
        group: "grid"
        strokeStyle: "#B0B0B0" ,
        strokeWidth: 1,
        x1: 0, y1: j,
        x2: @width, y2: j
      counter++
      break if (counter > @cellsX)
      j += @height/vertsteps


    start = 0#window.gridsize/2

    console.log "cellsX: #{@cellsX} and cellsy: #{@cellsY}"
    @createString()
    console.log @string
    gridsize = window.gridsize
    for x in [0..@cellsX]
      for y in [0..@cellsY]
        xcoord= x*gridsize
        ycoord = y*gridsize
        if @grid[x][y] == 1
          $("canvas").drawRect
            fillStyle: "#000"
            x: xcoord
            y: ycoord
            width: gridsize
            height: gridsize
            fromCenter: false
        else if @grid[x][y] == 2
          $("canvas").drawRect
            fillStyle: "#686868"
            x: xcoord
            y: ycoord
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
        if deltaY > 0
          window.gridsize += 1 if window.gridsize < 40
        else
          window.gridsize -= 1 if window.gridsize > 5
        if @timeout <= 0
          @timeout = window.setTimeout(@redrawContext, 20)
      "beforeunload": =>
        @save()
      "onload": =>
        @load()
