
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
    horizontal:
      offset: 0
      cells: 3
      drawn: 0
    vertical:
      offset: 0
      cells: 5
      drawn: 0
    border:
      left: 80
      right: 80
      top: 20
      bottom: 20
    cookie:
      name: "mazev2"
      content: ""
      options: { path: '/'}
    context: {}
    timout: 0
    mousein: null


  waypoints: []





  constructor: (@context) ->
    @grid = for x in [0..@config.horizontal.cells-1]
      for y in [0..@config.vertical.cells-1]
           new Tile(x, y)
    # @debug()
    @createConfig()
    @createHandlers()
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
    # Visible cells are either the total cells or all that can be fit into the width/height of the context
    visibleHorizontalCells =  Math.min  @config.context.width()/@config.gridsize
                             ,          @config.horizontal.cells
    visibleVerticalCells =  Math.min  (@config.context.width()/@config.context.height())*@config.gridsize
                            ,         @config.vertical.cells

    # Topmost corner of the grid
    startx = @config.border.left
    starty = @config.border.top
    startx_rec = @config.border.left
    starty_rec = @config.border.top

    # Take into account the offset
    # if @config.horizontal.offset < 0
    #   visible_width = @config.horizontal.length() + @config.horizontal.offset
    # else
    startx += @config.horizontal.offset
    visible_width = Math.min  @config.horizontal.length()
                    ,         @config.context.width()-@config.border.right-@config.border.left

    # visible_width += @config.horizontal.offset

    # if @config.vertical.offset < 0
    #   visible_height = @config.vertical.length() + @config.vertical.offset
    # else
    starty += @config.vertical.offset
    visible_height =  Math.min  @config.vertical.length()
                      ,         @config.context.height()-@config.border.bottom-@config.border.top
# #
    # visible_width += @config.vertical.offset


    # console.log "Dims: #{visible_width},#{visible_height}, max: #{@config.border.left + visible_width + @config.border.right},#{@config.border.top + visible_height + @config.border.bottom}"

    # console.log "Canvas: #{@config.context.width()},#{@config.context.height()}"




    # Save coordinates of cells in 2 lists for easy of drawing later
    xcells = [startx]
    ycells = [starty]

    i = 0

    # Compute the coordinates of the grid
    x = startx + @config.gridsize
    while (i < visibleHorizontalCells-1)
      if x > startx+visible_width
        break
      xcells.push x
      x += @config.gridsize
      i++

    j = 0
    y = starty + @config.gridsize
    while (j < visibleVerticalCells-1)
      if y > starty+visible_height
        break
      ycells.push y
      y += @config.gridsize
      j++



    # Draw the Tiles
    i = j = 0
    for x in xcells
      for y in ycells
        @grid[j][i].draw(x,y, @config.gridsize)
        i++
      i %= ycells.length
      j++

    xcells.push xcells[xcells.length-1]+@config.gridsize
    ycells.push ycells[ycells.length-1]+@config.gridsize


    # Then draw the grid
    # console.log "Rectangle left upper corner: #{startx_rec}, #{starty_rec}"
    # console.log "Rectangle size: #{visible_width}, #{visible_height}"
    $('canvas').drawRect
      strokeStyle: "#B0B0B0",
      strokeWidth: 2
      x: startx_rec, y: starty_rec
      width: visible_width
      height: visible_height
      fromCenter: false


    @config.horizontal.drawn = visible_width
    @config.vertical.drawn = visible_height


    for x in xcells
      $("canvas").drawLine
        strokeStyle: "#B0B0B0" ,
        strokeWidth: 1,
        x1: x, y1: starty,
        x2: x, y2: visible_height+starty
    for y in ycells
      $("canvas").drawLine
        strokeStyle: "#B0B0B0" ,
        strokeWidth: 1,
        x1: startx, y1: y,
        x2: startx+visible_width, y2: y



    # And the last step is a white border around the grid to cut off any excess rounded-rectangles.
    # Left Border
    $('canvas').drawRect
      fillStyle: "#FFF", #ColorLuminance(@color, @color_bias),
      x: 0, y: 0
      width: startx_rec-1
      height: @config.context.height()
      fromCenter: false

    # Right Border
    $('canvas').drawRect
      fillStyle: "#FFF", #ColorLuminance(@color, @color_bias),
      x: 0, y: starty_rec + visible_height+1
      width: @config.context.width()
      height: @config.context.height()- (starty_rec + visible_height)
      fromCenter: false

    # Bottom Border
    $('canvas').drawRect
      fillStyle: "#FFF", #ColorLuminance(@color, @color_bias),
      x: startx_rec+visible_width+1, y: 0
      width: @config.context.width() - startx_rec - visible_width
      height: @config.context.height()
      fromCenter: false
    $('canvas').drawRect
      fillStyle: "#FFF", #ColorLuminance(@color, @color_bias),
      x: 0, y: 0
      width: @config.context.width() - startx_rec - visible_width
      height: starty_rec-1
      fromCenter: false


    @config.timeout = 0

  recalculateCanvasDimensions: ->
    @config.context.width window.innerWidth-@config.border.left-@config.border.right
    @config.context.height window.innerHeight-@config.border.top-@config.border.bottom

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

  createHandlers: =>
    $('#save').on
      click: (e) =>
        $('#settings').hide()
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
        left = @config.border.left+$('#drawing').position().left
        top = @config.border.top+$('#drawing').position().top
        range_x =  [0..@config.horizontal.drawn]
        range_y =  [0..@config.vertical.drawn]
        inx = event.clientX-left in range_x
        iny = event.clientY-top in range_y
        if inx and iny
          console.log "Clicked in the grid"
          @config.mousein = event
        else
          console.log "Clicked outside the grid"
          # mouseout = event
      mousemove: (event) =>
        if @config.mousein
          @config.horizontal.offset += (event.clientX - @config.mousein.clientX)
          @config.vertical.offset += (event.clientY - @config.mousein.clientY)
          @config.mousein = event
          @config.timout = setTimeout @draw, 20
      mouseup: (event) =>
        @config.mousein = null





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




