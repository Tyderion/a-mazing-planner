class Obstacle

  constructor: (posx, posy, width, height, type) ->
    # Default
    # Width, height = 2,2 (2 cells high, 2 cells wide)
    @posx = posx
    @posy = posy
    @width = width
    @height = height
    @type = type
    @color = "#FFF"
    switch type
      when 1
        @color = "#000"
      when 2
        @color = "#B0B0B0"
      when 3
        @color = "#B00000"


    @type = 0 unless @type
    # console.log "type: #{@type}"


  draw: (xoff, yoff)->
    # Only draw if type is 1,2,3 or 4
    if 0 < @type < window.Game.BLOCKED
      $('canvas').drawRect
        fillStyle: @color,
        x: Math.floor(@posx*window.gridsize)+xoff, y: Math.floor(@posy*window.gridsize)+yoff
        width: (@width)*window.gridsize
        height: (@height)*window.gridsize
        fromCenter: false
        cornerRadius: window.gridsize/3,

class window.Game
  @game
  @BLOCKED = 5
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
    @xoffset = 100
    @yoffset = 100

    @movestart
    @cookiename = "maze"


    @checkDims()
    @string = string
    @grid = for row in [0..@cellsX]
      	for col in [0..@cellsY]
             new Obstacle(row, col, 1,1)
    @createhandlers()
    @load() if @string is ""
    @redrawContext()


  reset: ->
    $.removeCookie @cookiename
    @grid = for row in [0..@cellsX]
      for col in [0..@cellsY]
        new Obstacle(row, col, 1,1,0)
    @redrawContext()


  save: ->
    @createString()
    $.cookie @cookiename, @string

  load: ->
    @string = $.cookie(@cookiename)
    @readString()
    @createString()
    @debug()


  readString: ->
    if @string
      strings = @string.split(/;/)
      for obstacle in strings
        unless obstacle is ""
          attrs = obstacle.split(/,/)
          attrs = (parseInt(ele) for ele in attrs)
          [x, y, width, height, type] = attrs
          @grid[x][y] = new Obstacle(x,y, width, height, type)
          for i in [x..x+width-1]
            for j in [y..y+height-1]
              unless i is x and j is y
                @grid[i][j].type = @constructor.NONE

  createString: ->
    @string = ""
    for i in [0..@cellsX]
      for j in [0..@cellsY]
        ele = @grid[i][j]
        # If it is a tower, save it
        if (ele.type >= 1)
          # cellx, celly, width, height, type (just here to be future proof)
          @string += "#{i},#{j},#{ele.width},#{ele.height},#{ele.type};"

  debug: ->
    for i in [0..@cellsX]
      for j in [0..@cellsY]
        @string = "#{@string} #{@grid[j][i].type}"
      @string = "#{@string} \n"
    @string = "#{@string} \n\n"

  redrawContext:  =>
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
    return false if (x< 0 or y < 0 or x > @cellsX or y > @cellsY)
    current = @grid[x][y].type
    # console.log "Current: #{current}"
    # If the current is a tower, we can remove it
    if current is 1
      return true
    # If the current is empty, test if there is space for a tower
    else if current is 0
      val = true
      for i in [0..@obstacle_height-1]
        for j in [0..@obstacle_width-1]
          unless i is 0 and j is 0
            # console.log "Testing (#{x}+#{j},#{y}+#{i})"
            break unless val
            val = false unless @grid[x+j][y+i].type is 0
      # console.log "Testing (#{x},#{y}) and it is #{val}"
      return val
    else
      return false
    # console.log "Coordinate (#{x},#{y}) is #{current} and is it valid to switch? #{@test[index]}"

  click: (event) ->
    console.log event
    # console.log "@rec_width >= event.clientX: #{@rec_width} >= #{event.clientY}"
    inx = event.clientX in [@xoffset..@rec_width+@xoffset]
    iny = event.clientY in [@yoffset..@rec_height+@yoffset]
    if inx and iny
      x = Math.floor( Math.max(event.clientX-10-@xoffset,0) / window.gridsize)
      y = Math.floor( Math.max(event.clientY-10-@yoffset,0) / window.gridsize)
      console.log "Coordinates: (#{event.clientX},#{event.clientY}) and cell: (#{x},#{y}) with value: #{@grid[x][y].type}"
      current = @grid[x][y].type
      if current == 3
        newval = current*-1 +3 #Swap 0 and 2
        @grid[x][y].type= newval#new Obstacle(x,y,owidth, oheight, newval)

      if current < 2
        newval = current*-1 +1 #Swap 0 and 1
        if event.shiftKey
          newval = 3
          @obstacle_height = @obstacle_width = 1
        else
          @obstacle_height = @obstacle_width = 2

        if @checkValidity(x,y)
          @grid[x][y] = new Obstacle(x,y,@obstacle_width, @obstacle_height, newval)
          for i in [0..@obstacle_height-1]
            for j in [0..@obstacle_width-1]
              unless i is 0 and j is 0
                # Swap 5 and 0
                @grid[x+j][y+i].type = @grid[x+j][y+i].type*-1 + @constructor.BLOCKED
          # console.log @grid[x][y]
      @redrawContext()
      @save()


  drawGrid: (x,y) ->
    steps = @width/window.gridsize
    vertsteps = (@height/@width)*steps
    @rec_width = Math.min (@width/steps)*(@cellsX+1), @width-@xoffset
    @rec_height = Math.min (@height/vertsteps)*(@cellsY+1), @height-@yoffset
    $('canvas').drawRect
      layer: true
      name: "border"
      group: "grid"
      strokeStyle: "#000",
      strokeWidth: 2
      x: x+@xoffset, y: y+@yoffset,
      width: @rec_width
      height: @rec_height
      fromCenter: false



    i = 0
    while (i < @rec_width)
      $("canvas").drawLine
        layer: true
        name: "vline#{i}"
        group: "grid"
        strokeStyle: "#B0B0B0" ,
        strokeWidth: 1,
        x1: i+@xoffset, y1: @yoffset,
        x2: i+@xoffset, y2: @rec_height+@yoffset
      i += (@width/steps)


    j = 0
    while (j < @rec_height)
      $("canvas").drawLine
        layer: true
        name: "hline#{j}"
        group: "grid"
        strokeStyle: "#B0B0B0" ,
        strokeWidth: 1,
        x1: @xoffset, y1: j+@yoffset,
        x2: @rec_width+@xoffset, y2: j+@yoffset
      j += @height/vertsteps

    gridsize = window.gridsize
    for x in [0..@cellsX]
      for y in [0..@cellsY]
        @grid[x][y].draw(@xoffset, @yoffset)

  toggleMenu: ->
    $('#settings').toggle()

  createhandlers: ->
    $(window).on
      click: (e) =>
        if e.button == 0
          @click(e)
      mousemove: (e) =>
        if @mousedown
          # Calculate the x/y difference
          xdiff = @mousedown.clientX - e.clientX
          ydiff = @mousedown.clientY - e.clientY
          # Adjust by that difference
          @xoffset -= xdiff
          @yoffset -= ydiff
          @timeout = window.setTimeout(@redrawContext, 20) if @timeout <= 0
          # Save new position
          @mousedown = e
      mousedown: (e) =>
        unless $('#settings').is ":visible"
          @mousedown = e
      mouseup: (e) =>
        @mousedown = null
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
        @reset()
        return false
    $('#settings').on
      click: (e) =>
        e.stopPropagation()
