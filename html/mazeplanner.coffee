class Obstacle

  constructor: (posx, posy, width, height, type, num = -1) ->
    # Default
    # Width, height = 2,2 (2 cells high, 2 cells wide)
    # console.log "Obstacle"
    # console.log "Obstacle with num#{num}"
    @posx = posx
    @posy = posy
    @width = width
    @height = height
    @type = type
    @color = "#FFF"
    @num = num
    @color_bias = 0
    switch type
      when 1
        @color = "#000"
      when 2
        @color = "#B0B0B0"
      when 3
        @color = "#B00000"
      when 5
        @color = "#00FFFF"


    @type = 0 unless @type
    # console.log "type: #{@type}"

  adjustBias: (adjustment) ->
    @color_bias += adjustment


  draw: (xoff, yoff)->
    # Only draw if type is smaller than window.Game.BLOCKED
    if 0 < @type < window.Game.BLOCKED
      x = Math.floor(@posx*window.gridsize)+xoff
      y = Math.floor(@posy*window.gridsize)+yoff
      width = @width*window.gridsize
      height = @height*window.gridsize
      $('canvas').drawRect
        fillStyle: ColorLuminance(@color, @color_bias),
        x: x, y: y
        width: width
        height: height
        fromCenter: false
        cornerRadius: window.gridsize/3,
      if @num >= 0
        $("canvas").drawText
          fillStyle: "#9cf"
          strokeStyle: "#25a"
          strokeWidth: 2
          x: x+width/2
          y: y+height/2
          font: "#{window.gridsize/3*2}pt Verdana, sans-serif"
          text: "#{@num}"


class window.Game
  @game
  @BLOCKED = 99
  @it: ->
    return @game



  constructor: (context, cellsX, cellsY, string, xoffset = 100, yoffset = 100) ->
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
    @xoffset = xoffset
    @yoffset = yoffset

    @movestart
    @cookiename = "maze"
    @path = []


    @checkDims()
    @string = string
    @grid = for row in [0..@cellsX]
      	for col in [0..@cellsY]
             new Obstacle(row, col, 1,1)
    @createhandlers()
    @load() if @string is ""
    @redrawContext()
    $('#start').remove()

  adjustSize: (height, width)->
    grid = @grid
    @cellsX = width
    @cellsY = height
    @grid = for row in [0..@cellsX]
        for col in [0..@cellsY]
          if grid[row]?[col] is undefined
             new Obstacle(row, col, 1,1)
          else
            @obstacle_width = grid[row][col].width
            @obstacle_height = grid[row][col].height
            if col+@obstacle_height > @cellsY or row+@obstacle_width > @cellsX
              new Obstacle(row, col, 1,1)
            else
              new Obstacle(row, col, @obstacle_width ,  @obstacle_height, grid[row][col].type, grid[row][col].num)


  reset: ->
    $.removeCookie @cookiename
    @grid = for row in [0..@cellsX]
      for col in [0..@cellsY]
        new Obstacle(row, col, 1,1,0)
    @path = []
    @redrawContext()


  save: ->
    @createString()
    $.cookie @cookiename, @string

  load: ->
    @string = $.cookie(@cookiename)
    @readString()
    @createString()
    # @debug()


  readString: ->
    if @string
      strings = @string.split(/;/)
      for obstacle in strings
        unless obstacle is ""
          attrs = obstacle.split(/,/)
          attrs = (parseInt(ele) for ele in attrs)
          [x, y, width, height, type,num] = attrs
          @grid[x][y] = new Obstacle(x,y, width, height, type, num)
          if type is 3
            @path[num] = [x,y]
      # console.log "Parsed #{numobstacles} Obstacles and #{numblocked} Blocked cells"
      # @debug()

  createString: ->
    @string = ""
    for i in [0..@cellsX]
      for j in [0..@cellsY]
        ele = @grid[i][j]
        # If it is a tower, save it
        if (ele.type >= 1)
          # cellx, celly, width, height, type (just here to be future proof)
          num = ""
          if ele.type == 3
            index = 0
            for coords in @path
              if coords[0] == i and coords[1] == j
                num = ",#{index}"
              index++
          #   console.log "Searching: [#{i},#{j}] in the path"
          #   console.log "Path number: #{num}"
          # console.log "Number is: #{num}!"
          @string += "#{i},#{j},#{ele.width},#{ele.height},#{ele.type}#{num};"
    # console.log @string

  debug: ->
    string = ""
    for i in [0..@cellsX]
      for j in [0..@cellsY]
        string = "#{string} #{@grid[j][i].type}"
      string = "#{string} \n"
    string = "#{string} \n\n"
    console.log string
    @createString()
    console.log @string.split /;/

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
    # If its outside or part of it is outside, it is not valid xD
    return false if (x< 0 or y < 0 or x > @cellsX or y > @cellsY or x+@obstacle_width-1 > @cellsX or y+@obstacle_height-1 > @cellsY)
    # console.log "Position #{x},#{y} with obstacle height: #{@obstacle_height} and cells: (#{@cellsX},#{@cellsY}"
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
            break unless val
            val = false unless @grid[x+j][y+i].type is 0
            # console.log "Testing (#{x}+#{j},#{y}+#{i}): #{val}, it's type is: #{@grid[x+j][y+i].type}"
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
      # console.log "Coordinates: (#{event.clientX},#{event.clientY}) and cell: (#{x},#{y}) with value: #{@grid[x][y].type}"
      current = @grid[x][y].type
      if current == 3
        @grid[x][y].type= 0#new Obstacle(x,y,owidth, oheight, newval)
        index = 0
        for coords in @path
          if coords[0] == x and coords[1] == y
            path = []
            if (index-1 >= 0)
              path.push p for p in @path[0..index-1]
            if (index+1 <= @path.length)
              path.push p for p in @path[index+1..@path.length]
            @path = path
          index++


      if current < 2
        newval = current*-1 +1 #Swap 0 and 1
        if event.shiftKey
          newval = 3
          @obstacle_height = @obstacle_width = 1
          @path.push [x,y]
        else
          @obstacle_height = @obstacle_width = 2

        if @checkValidity(x,y)
          @grid[x][y] = new Obstacle(x,y,@obstacle_width, @obstacle_height, newval, if newval is 3 then @path.length-1 else undefined )
          for i in [0..@obstacle_height-1]
            for j in [0..@obstacle_width-1]
              unless i is 0 and j is 0
                # Swap 5 and 0
                # console.log "Swapping: #{@grid[x+j][y+i].type}"
                @grid[x+j][y+i].type = @grid[x+j][y+i].type*-1 + @constructor.BLOCKED
          # console.log @grid[x][y]
      # @debug()
      @redrawContext()
      @save()


  removePath: ->
    for row in [0..@cellsX]
      for col in [0..@cellsY]
        current = @grid[row][col].type
        if current is 5
          @grid[row][col] = new Obstacle(row, col, 1,1,0)
    index = 0
    for coords in @path
      # console.log coords
      @grid[coords[0]][coords[1]] = new Obstacle(coords[0],coords[1], 1,1, 3, index)
      index++
    @redrawContext()

  calculatePath: ->
    @removePath()
    # console.log @path

    unless @path.length < 2

      array = for row in [0..@cellsX]
        for col in [0..@cellsY]
          current = @grid[row][col].type
          if current in [1, @constructor.BLOCKED] then 0 else 1


      # console.log  array

      # graph = new Graph([[1, 1, 1, 1], [0, 2, 1, 0], [0, 0, 1, 1]])
      graph = new Graph(array)

      index_start = 0
      result = []
      while (index_start < @path.length-1)
        start = graph.nodes[@path[index_start][0]][@path[index_start][1]]
        end = graph.nodes[@path[index_start+1][0]][@path[index_start+1][1]]
        # console.log "Calculating path from #{index_start} to #{index_start+1}"§
        result.push node for node in  astar.search(graph.nodes, start, end)
        index_start++

      result.unshift(graph.nodes[@path[0][0]][@path[0][1]])

      @animatePath(0, result)

  animatePath: (index, result) ->
    window.setTimeout =>
      x = result[index].x
      y = result[index].y
      element = @grid[x][y]
      if element.type is 5
        # console.log "Adjusting bias for #{x},#{y}: #{element.color}"
        element.adjustBias(-0.2)
        # console.log "Adjusted bias for #{x},#{y}: #{element.color}"
      else if element.type == 3
        @grid[x][y] = new Obstacle(x, y, 1, 1, 5, element.num)
      else
        @grid[x][y] = new Obstacle(x, y, 1, 1, 5)
      @redrawContext()
      @animatePath(index+1, result) if index < result.length-1
      if index is result.length-1
        alert "Your Maze is #{result.length} Tiles long."
    , window.gridsize*6



# result is an array containing the shortest path




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
    $("html").on
      click: (e) =>
        if e.button == 0
          @click(e)
      mousemove: (e) =>
        if @mousedown
          # Calculate the x/y difference
          xdiff = @mousedown.clientX - e.clientX
          ydiff = @mousedown.clientY - e.clientY
          # Adjust by that difference
          # console.log e
          if $('#settings').is ":visible" #and e.target is not
            ele = $('#settings')
            # console.log ele.position()
            ele.css
              top: ele.position().top -= ydiff
              left: ele.position().left -= xdiff
          else
            @xoffset -= xdiff
            @yoffset -= ydiff
            @timeout = window.setTimeout(@redrawContext, 20) if @timeout <= 0
          # Save new position
          @mousedown = e
      mousedown: (e) =>
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
        if e.shiftKey
          switch String.fromCharCode(e.charCode)
            when "C"
              @removePath()
        unless e.metaKey or e.shiftKey or e.altKey or e.controlKey
          switch String.fromCharCode(e.charCode)
            when "o"
              @toggleMenu()
            when "r"
              if confirm("Do you really want to reset the Maze?")
                @reset()
            when "c"
              @calculatePath()

      load: =>
        @load()
    $('#resetMaze').on
      click: (e) =>
        e.stopPropagation()
        @reset()
        return false
    $('#settings').on
      click: (e) =>
        e.stopPropagation()
    $('#settings').on
      change: (e) =>
        id = $(e.currentTarget).attr 'id'
        property = id[..id.length-7]
        $("#current#{property}").html (parseInt($("##{property}slider").get(0).value)+1)
      mousemove: (e) =>
        e.stopPropagation()
    , "[id*=slider]"
    $('#save').on
      click: =>
        @adjustSize(parseInt($("#heightslider").get(0).value), parseInt($("#widthslider").get(0).value))
        # this = new Game(@context, @celllX, @cellsY, @string, @xoffset, @yoffset)
        @redrawContext()
