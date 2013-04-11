class Obstacle

  constructor: (posx, posy, width, height, type) ->
    # Default
    # Width, height = 2,2 (2 cells high, 2 cells wide)
    @posx = posx
    @posy = posy
    @width = width
    @width = width
    @height = height
    @type = type
    @type = 0 unless @type


  draw: ->
    if @type is 1
      $('canvas').drawRect
        fillStyle: "#000",
        x: Math.floor(@posx*window.gridsize)+1, y: Math.floor(@posy*window.gridsize)
        width: (@width)*window.gridsize
        height: (@height)*window.gridsize
        fromCenter: false

class window.Game
  @game
  @it: ->
    return @game





  constructor: (context, cellsX, cellsY, string) ->
    @width = 0
    @height = 0
    @cellsX = cellsX-1
    @cellsY = cellsY-1
    @context = context
    @constructor.game = this
    @timeout = 0
    @counter = 0
    @rec_width = 0
    @rec_height = 0
    @obstacle_height = 2
    @obstacle_width = 2


    @checkDims()
    @string = string
    @grid = for row in [0..@cellsX]
      	for col in [0..@cellsY]
             new Obstacle(row, col, 1,1)
    @createhandlers()
    @load() if @string is ""
    @redrawContext()


  reset: ->
    $.removeCookie 'test',
      path: '/'
    # console.log "Removed cookie"
    # console.log $.cookie()
    @grid = for row in [0..@cellsX]
      for col in [0..@cellsY]
        new Obstacle(row, col, 1,1,0)
    @redrawContext()


  save: ->
    #TODO: Save cellsX/Y in the cookie too, maybe use cookie title or cvs or some cookie manager (jquery-plugin or similar)
    @createString()
    # console.log "Saving string as cookie: #{@string}"
    $.cookie "test", @string,
      path: "/"
    # console.log "Saved #{@string} "#\n cookie: #{$.cookie('test')}"

  load: ->
    @string = $.cookie('test')
    # console.log "Loading: #{@string}"
    @readString()
    @string = ""
    @debug()
    # console.log @string


  readString: ->
    if @string
      p = 0
      while (p < @string.length)
        # console.log "p: #{p} and p/(@cellsX+1): #{Math.floor p/(@cellsX+1)} and p%@cellsY: #{p%(@cellsX+1)}"
        # x = Math.floor p/(@cellsX+1)
        # y = p%(@cellsX+1)
        # console.log "grid[x][y] = grid#{[x]},#{[y]}"
        # @grid[x][y] = new Obstacle(x,y, 2,2, parseInt @string[p])

        p++

  createString: ->
    #TODO: Think of a better way to save the obstacles
    @string = ""
    for i in [0..@cellsX]
      for j in [0..@cellsY]
        @string += @grid[i][j].type
    # matches = @string.match(new RegExp('1', "g"))
    # length = matches.length unless matches is null
    # console.log "String representation has #{length} of 1s"

  debug: ->
    for i in [0..@cellsX]
      for j in [0..@cellsY]
        @string = "#{@string} #{@grid[j][i].type}"
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
    @width = window.innerWidth-20 if @width != window.innerWidth-20
    @height = window.innerHeight-20 if @height != window.innerheight-20



  # Return true if the block at x,y is or can be the topleft cell of a tower
  checkValidity: (x,y) =>
    # If its outside, it is not valid xD
    return false if (x< 0 or y < 0 or x >= @cellsX or y >= @cellsY)
    current = @grid[x][y].type
    # If the current is a tower, we can remove it
    if current is 1
      return true
    # If the current is empty, test if there is space for a tower
    else if current is 0
      val = true
      for i in [0..@obstacle_height-1]
        for j in [0..@obstacle_width-1]
          unless i is 0 and j is 0
            # console.log "Testing (#{x+j},#{y+i})"
            break unless val
            val = false unless @grid[x+j][y+i].type is 0
      return val
    else
      return false
    # console.log "Coordinate (#{x},#{y}) is #{current} and is it valid to switch? #{@test[index]}"

  click: (event) ->
    @test = []
    # console.log "@rec_width >= event.clientX: #{@rec_width} >= #{event.clientY}"
    if @rec_width >= event.clientX and @rec_height >= event.clientY
      x = Math.floor( Math.max(event.clientX-10,0) / window.gridsize)
      y = Math.floor( Math.max(event.clientY-10,0) / window.gridsize)
      console.log "Coordinates: (#{event.clientX},#{event.clientY}) and cell: (#{x},#{y})"
      current = @grid[x][y].type
      # console.log  "Current: #{current}"
      if current <= 2
        newval = current*-1 +1 #Swap 0 and 1
        if @checkValidity(x,y)
          @grid[x][y] = new Obstacle(x,y,@obstacle_width, @obstacle_height, newval)
          for i in [0..@obstacle_height-1]
            for j in [0..@obstacle_width-1]
              unless i is 0 and j is 0
                # console.log "Testing (#{x+j},#{y+i})"
                # break unless val
                # val = false unless @grid[x+j][y+i].type is 0
                @grid[x+j][y+i].type = @grid[x+j][y+i].type*-1 + 5
          console.log @grid[x][y]
        @redrawContext()
      @save()


  drawGrid: (x,y) ->
    steps = @width/window.gridsize
    vertsteps = (@height/@width)*steps

    # console.log "Steps: #{steps}"
    @rec_width = Math.min (@width/steps)*(@cellsX+1), @width
    @rec_height = Math.min (@height/vertsteps)*(@cellsY+1), @height
    $('canvas').drawRect
      layer: true
      name: "border"
      group: "grid"
      strokeStyle: "#000",
      strokeWidth: 2
      x: x, y: y,
      width: @rec_width
      height: @rec_height
      fromCenter: false



    i = 0
    # counter = 0
    while (i < @rec_width)
      $("canvas").drawLine
        layer: true
        name: "vline#{i}"
        group: "grid"
        strokeStyle: "#B0B0B0" ,
        strokeWidth: 1,
        x1: i, y1: 0,
        x2: i, y2: @rec_height
      # counter++
      # break if (counter > @cellsX)
      i += (@width/steps)


    j = 0
    # counter = 0
    while (j < @rec_height)
      $("canvas").drawLine
        layer: true
        name: "hline#{j}"
        group: "grid"
        strokeStyle: "#B0B0B0" ,
        strokeWidth: 1,
        x1: 0, y1: j,
        x2: @rec_width, y2: j
      # counter++
      # break if (counter > @cellsX)
      j += @height/vertsteps


    start = 0#window.gridsize/2

    # console.log "cellsX: #{@cellsX} and cellsy: #{@cellsY}"
    @createString()
    # console.log @string
    gridsize = window.gridsize
    for x in [0..@cellsX]
      for y in [0..@cellsY]
        @grid[x][y].draw()

  toggleMenu: ->
    $('#settings').toggle()

  createhandlers: ->
    # TODO: move the board around! :)
    $(window).on
      click: (e) =>
        @click(e)
      resize: (e) =>
        # Use Timeout....
        @timeout = window.setTimeout(@redrawContext, 20) if @timeout <= 0
      mousewheel: (e, delta, deltaX, deltaY) =>
        if deltaY > 0
          window.gridsize += 1 if window.gridsize < 300
        else
          window.gridsize -= 1 if window.gridsize > 5
        if @timeout <= 0
          @timeout = window.setTimeout(@redrawContext, 20)
      beforeunload: =>
        @save()
        return null
      keypress: (e) =>
        if String.fromCharCode(e.charCode) == "o"
          @toggleMenu()
      # keyup: (e) =>
      #   console.log e.keyCode
      load: =>
        @load()
    $('#reset').on
      click: (e) =>
        e.stopPropagation()
        console.log "Click"
        @reset()
        return false
    $('#settings').on
      click: (e) =>
        e.stopPropagation()
