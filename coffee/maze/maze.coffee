
class Tile
  type: null
  width: 1
  height: 1
  constructor: (@x, @y) ->
    if Math.random() > 0.5
      @type =  true


  draw: (xcoords, ycoords, gridsize) ->
    if @type
      $('canvas').drawRect
        fillStyle: "#FF00FF", #ColorLuminance(@color, @color_bias),
        x: xcoords, y: ycoords
        width: @width*gridsize
        height: @height*gridsize
        fromCenter: false
        cornerRadius: gridsize/4,



  string: ->
    return "(#{@x},#{@y})"

class Maze


  config:
    animate: false
    cursor: false
    overlay: false
    gridsize: 50
    background_color: "#FFF"
    horizontal:
      offset: 0
      cells: 5
      drawn: 0
    vertical:
      offset: 0
      cells: 5
      drawn: 0
    border:
      left: 60
      right: 100
      top: 60
      bottom: 60
    cookie:
      name: "mazev2"
      content: ""
      options: { path: '/'}
    context: {}
    timout: 0
    mousein: null
    mousout: null


  waypoints: []





  constructor: (@context) ->
    @grid = for x in [0..@config.horizontal.cells-1]
      for y in [0..@config.vertical.cells-1]
           new Tile(x, y)
    # @debug()
    @createConfig()
    @createHandlers()
    @config.horizontal.offset =  @config.vertical.offset = @config.gridsize
    $('#drawing').css
      position: "absolute"
      top: @config.border.top
      left: @config.border.left



  createConfig: ->
    @config.horizontal.length =  =>
      Math.min  @config.horizontal.cells*@config.gridsize
      ,         @config.context.width()-@config.border.left
    @config.vertical.length = =>
      Math.min  @config.vertical.cells*@config.gridsize
      ,         @config.context.height()-@config.border.top
    @config.context.width = (newwidth) =>
      if newwidth
        @context.canvas.width = newwidth
      else
        @context.canvas.width
    @config.context.height = (newheight) =>
      if newheight
        @context.canvas.height = newheight
      else
        @context.canvas.height

    # console.log "conf context height is : #{@config.context.height}"


  draw: =>
    $('canvas').clearCanvas()
    @recalculateCanvasDimensions()
    #Offset
    # visibleVerticalCells =  Math.floor Math.min  (@config.context.width()/@config.context.height())*@config.gridsize
                            # ,         @config.vertical.cells
    # console.log "vertical: #{visibleVerticalCells} + offset: #{yoffset}"
    # Topmost corner of the grid
    startx = @config.border.left
    starty = @config.border.top
    startx_rec = @config.border.left
    starty_rec = @config.border.top

    visible_width = Math.min  @config.horizontal.length()
                    ,         @config.context.width()-@config.border.right

    visible_height =  Math.min  @config.vertical.length()
                      ,         @config.context.height()-@config.border.bottom

    # To check if a click is inside or outside
    @config.horizontal.drawn = visible_width
    @config.vertical.drawn = visible_height

    xoffset = Math.floor(@config.horizontal.offset/@config.gridsize)
    yoffset = Math.floor(@config.vertical.offset/@config.gridsize)
    # Take into account the offset
    # if @config.horizontal.offset < 0
    #   visible_width = @config.horizontal.length() + @config.horizontal.offset
    # else
    if xoffset > -1
      startx +=  @config.horizontal.offset
    else
      startx += @config.horizontal.offset - xoffset* @config.gridsize # Modulo but not with builtin because of floor for




    if yoffset >= 0
      starty += @config.vertical.offset
    else
      starty += @config.vertical.offset - yoffset* @config.gridsize # Modulo but not with builtin because of floor for






    visibleHorizontalCells =  Math.floor visible_width/@config.gridsize-(if xoffset > 0 then xoffset else 0), @grid[0].length-1
    visibleVerticalCells =  Math.floor Math.min visible_height/@config.gridsize-(if yoffset > 0 then yoffset else 0), @grid[0].length-1

    xcells = []
    ycells = []





    i = 0
    # Compute the coordinates of the grid
    x = startx
    # Stopper is positive if stopper-many tiles could be displayed more on the canvas, but the grid of the maze is not big enough
    stopper = visibleHorizontalCells-xoffset-@grid.length+1
    if visibleHorizontalCells >=  0
      # Add on cell to the left if any are visible (to be able to view partial cells)
      xcells.push startx-@config.gridsize if visibleHorizontalCells + xoffset > 0 and visibleHorizontalCells <= @grid.length

      # While we can still draw more tiles
      while (i < visibleHorizontalCells-(if stopper > 0 then stopper else 0))
        # Add the x-coordinate of the row to the list
        xcells.push x if  x > 0 # Only push positive cordinates
        x += @config.gridsize
        i++



    j = 0
    y = starty
    # Stopper is positive if stopper-many tiles could be displayed more on the canvas, but the grid of the maze is not big enough
    stopper = visibleVerticalCells-yoffset-@grid[0].length+1
    if visibleVerticalCells >= 0
      # Add on cell to the top if any are visible (to be able to view partial cells)
      ycells.push starty-@config.gridsize if visibleVerticalCells + yoffset >= 0
      # While we can still draw more tiles
      while (j < visibleVerticalCells-(if stopper > 0 then stopper else 0))
        # Add the y-coordinate of the col to the list
        ycells.push y if y > 0 # Only push positive cordinates
        y += @config.gridsize
        j++


    # Draw the Tiles
    i = if yoffset < 0 then -yoffset else 0
    j = if xoffset < 0 then -xoffset else 0

    for x in xcells
      for y in ycells
        @grid[j]?[i]?.draw(x,y, @config.gridsize)
        i++
      i = if yoffset < 0 then -yoffset else 0
      j++


    # Draw the rectangle-border around the tiles
    $('canvas').drawRect
      strokeStyle: "#B0B0B0",
      strokeWidth: 2
      x: startx_rec, y: starty_rec
      width: visible_width
      height: visible_height
      fromCenter: false


    # Push one more coordinate for the last line
    ycells.push ycells[ycells.length-1]+@config.gridsize if ycells.length > 0
    xcells.push xcells[xcells.length-1]+@config.gridsize if xcells.length > 0

    for x in xcells
      $("canvas").drawLine
        strokeStyle: "#B0B0B0" ,
        strokeWidth: 1,
        x1: x, y1: ycells[0],
        x2: x, y2: ycells[ycells.length-1]
    for y in ycells
      $("canvas").drawLine
        strokeStyle: "#B0B0B0" ,
        strokeWidth: 1,
        x1: xcells[0], y1: y,
        x2: xcells[xcells.length-1], y2: y




    # Finally draw some rectangles around the border-rectangle to cut off any tiles.
    # Left Border
    opacity = 0.5 ## Debug = 0.5, Prod = 1

    $('canvas').drawRect
      fillStyle: @config.background_color,
      x: 0, y: 0
      width: startx_rec-1
      height: @config.context.height()
      fromCenter: false
      opacity: opacity

    # Bottom Border
    $('canvas').drawRect
      fillStyle: @config.background_color,
      x: 0, y: starty_rec + visible_height+1
      width: @config.context.width()
      height: @config.context.height()- (starty_rec + visible_height)
      fromCenter: false
      opacity: opacity

    # #Top Border
    $('canvas').drawRect
      fillStyle: @config.background_color,
      x: 0, y: 0
      width: @config.context.width()
      height: starty_rec-1
      fromCenter: false
      opacity: opacity
    # Right Border
    $('canvas').drawRect
      fillStyle: @config.background_color,
      x: startx_rec+visible_width+1, y: 0
      width: @config.context.width()- (startx_rec + visible_width)
      height: @config.context.height()
      fromCenter: false
      opacity: opacity



    @config.timeout = 0

  recalculateCanvasDimensions: ->
    @config.context.width window.innerWidth-@config.border.right-$('#drawing').position().left
    @config.context.height window.innerHeight-@config.border.bottom-$('#drawing').position().top

  debug: =>
    string = ""
    console.log @grid[0]
    for y in [0..@config.vertical.cells-1]
      for x in [0..@config.horizontal.cells-1]
        string += " #{@grid[x][y].string()}"

      string += "\n"
    string += "\n"
    console.log string
    console.log "Grid is: #{@grid.length}x#{@grid[0].length}"

  inRectangle: (event) =>
    left = @config.border.left+$('#drawing').position().left
    top = @config.border.top+$('#drawing').position().top
    range_x =  [0..@config.horizontal.drawn]
    range_y =  [0..@config.vertical.drawn]
    inx = event.clientX-left in range_x
    iny = event.clientY-top in range_y
    return inx and iny

  createHandlers: =>
    $('#save').on
      click: (e) =>
        $('#settings').hide()
        e.stopPropagation()
        @config.started = true
        @draw()
    $('#drawing').on
      mousewheel: (e, delta, deltaX, deltaY) =>
        if deltaY > 0
          @config.gridsize += 1 if @config.gridsize
        else
          @config.gridsize -= 1 if @config.gridsize > 5

        if @config.timeout <= 0
          @config.timeout = window.setTimeout(@draw, 20)
    $('html').on
      mousedown: (event) =>
        if @config.started
          if @inRectangle(event)
            @config.mousein = event
          else
            @config.mouseout = event
            console.log "Clicked outside the grid"
            # mouseout = event
      mousemove: (event) =>
        # console.log "Mousemove"
        if @config.mousein
          @config.horizontal.offset += (event.clientX - @config.mousein.clientX)
          @config.vertical.offset += (event.clientY - @config.mousein.clientY)
          @config.mousein = event
          @config.timout = setTimeout @draw, 20
          @config.moved = true
        if @config.mouseout
          xdiff = event.clientX - @config.mouseout.clientX
          if xdiff < 0  or @config.border.left + @config.horizontal.drawn + xdiff < @config.context.width()
            @config.border.left += xdiff
          if @config.border.left+xdiff < 1
           @config.border.left = 1
          @config.moved = true


          ydiff = event.clientY - @config.mouseout.clientY
          if ydiff < 0 or @config.border.top + @config.vertical.drawn + ydiff < @config.context.height()
            @config.border.top += ydiff
          if @config.border.top+ydiff < 1
           @config.border.top = 1


          # @config.border.top += (event.clientY - @config.mouseout.clientY)
          # @config.border.top = 1 if @config.border.top < 1
          @config.mouseout = event
          @config.timout = setTimeout @draw, 20
      mouseup: (event) =>
        console.log "Mousup"
        if @inRectangle(event)
          unless @config.moved
            left = @config.border.left+$('#drawing').position().left
            top = @config.border.top+$('#drawing').position().top
            x = Math.floor((event.clientX-left-@config.horizontal.offset)/@config.gridsize)+1
            y = Math.floor((event.clientY-top-@config.vertical.offset)/@config.gridsize)+1
            console.log "Clicked in the grid on row #{event.clientX},#{event.clientY} -> #{x},#{y}"
            @grid[x][y].type = !@grid[x][y].type
            @draw()
        @config.mousein = null
        @config.mouseout = null
        @config.moved = false





$ ->
  drawingCanvas = $("#drawing").get(0)
  if drawingCanvas.getContext
    $('p').remove()
    # Initaliase a 2-dimensional drawing context
    context = drawingCanvas.getContext('2d');
    prmstr = window.location.search.substr(1)
    prmarr = prmstr.split("&")
    params = {}
    i = 0

    while i < prmarr.length
      tmparr = prmarr[i].split("=")
      params[tmparr[0]] = tmparr[1]
      i++
    window.maze = new Maze(context)
    # console.log maze.config.context.width()




