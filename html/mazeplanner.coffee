class window.Game
  constructor: (width, height, context) ->
    @width = width
    @height = height
    @context = context
    @grid = #[][]
    @test = []
    @timeout = 0
    @counter = 0
    @string = ""
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
    console.log "Testing (#{x},#{y})"
    return false if (x< 0 or y < 0 or x > @width or y > @height)
    index = x*@width+y
    unless @test[index]  is  undefined
      return @test[index]
    @counter += 1
    if @counter > 50
      console.log "STOPPING TOO MUCH RECURSION!!!!"
      return false
    current = @grid[x][y]
    # If all 4 are empty, tower can be placed
    console.log "Validity of #{x}#{y}  depends on ..."
    if @grid[x+1][y] == @grid[x][y+1] == @grid[x+1][y+1] == current
      if current == 0
        @test[index] = true
      else
        # Tower can be placed if the rest of the black fields are only towers
        #TODO: from a vertical 2x4 space can the middle be removed

        for h in [-1..1]
          for v in [-1..1]
            unless h == 0 and v == 0
              console.log "Offset (#{h},#{v})"
              if @checkValidity(x+h, y+v)
                @test[index] = false
                break
          break unless @test[index]

        @test[index] = true if @test[index] is undefined
    else
     @test[index] = false

    console.log "Testing #{x}#{y} result is: #{@test[index]}"
    return @test[index]

  click: (event) ->
    @test = []
    @counter = 0
    # @debug()
    x = Math.floor( event.clientX / window.gridsize)
    y = Math.floor( event.clientY / window.gridsize)
    # console.log "Click: (#{event.clientX},#{event.clientY}) and cell: (#{x},#{y})"

    current = @grid[x][y]
    if current <= 2
      newval = @grid[x][y]*-1 +1 #Swap 0 and 1
      # console.log "This click is valid? #{valid}"
      if @checkValidity(x,y)
        for i in [x..x+1]
          for j in [y..y+1]
            @grid[i][j] = newval

      # @grid[x][y] = newval

      # @debug()
      # console.log @string
      @string = ""
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
