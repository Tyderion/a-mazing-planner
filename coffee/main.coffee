
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
        @color = "#686868"
      when 2
        @color = "#B0B0B0"
      when 3
        @color = "#B00000"
      when 4
        @color = "#FF00FF"
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
          x: x+window.gridsize/2
          y: y+window.gridsize/2
          font: "#{window.gridsize/3*2}pt Verdana, sans-serif"
          text: "#{@num}"
class Overlay extends Obstacle

  constructor: (game) ->
    @x = 0
    @y = 0
    @game = game
    @redraw = false
    @timout = 0



  draw: (x,y ,xoffset, yoffset, rec_width, rec_height, fake, width, height, num) ->
    if fake
      # x = Math.floor( Math.max(e.clientX-10-xoffset,0) / window.gridsize)
      # y = Math.floor( Math.max(e.clientY-10-yoffset,0) / window.gridsize)
      # console.log "Coordinates: (#{e.clientX},#{e.clientY}) and cell: (#{x},#{y}) with value: #{grid[x][y].type}"
      fake = new Obstacle(x,y,width, height,4, num)
      if @x != x or @y != y
        if @timout
          clearTimeout(@timeout)
        @timout = setTimeout @game.redrawContext, 5
      fake.draw(xoffset, yoffset)
      @x = x
      @y = y
      @redraw = true
    else
      if @redraw
        if @timout
          clearTimeout(@timeout)
        @timout = setTimeout @game.redrawContext, 5
      @redraw = false

class Tile
  type: null
  width: 1
  height: 1
  constructor: (@x, @y) ->


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
    vertical:
      offset: 0
      cells: 5
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
      Math.min @config.horizontal.cells*@config.gridsize, @config.context.width()-@config.border.left - @config.horizontal.offset
    @config.vertical.length = =>
      Math.min @config.vertical.cells*@config.gridsize, @config.context.height()-@config.border.top - @config.vertical.offset
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
    visibleHorizontalCells = Math.min @config.context.width()/@config.gridsize, @config.horizontal.cells
    # console.log "visible-cells: #{visibleHorizontalCells} - #{@config.horizontal.cells}"
    visibleVerticalCells = Math.min (@config.context.width()/@config.context.height())*@config.gridsize, @config.vertical.cells
    startx = @config.border.left
    starty = @config.border.top
    if @config.horizontal.offset < 0
      visible_width = @config.horizontal.length() + @config.horizontal.offset
    else
      startx += @config.horizontal.offset
      visible_width = Math.min @config.horizontal.length(), @config.context.width()-@config.border.right-@config.border.left

    if @config.vertical.offset < 0
      visible_height = @config.vertical.length() + @config.vertical.offset
    else
      starty += @config.vertical.offset
      visible_height = Math.min @config.vertical.length(), @config.context.height()-@config.border.bottom-@config.border.top

    # if @config.border.left + visible_width + @config.border.right > @config.context.width()
    #   visible_width -= @config.border.right

    # if @config.border.top + visible_height + @config.border.bottom > @config.context.height()
    #   visible_height -= @config.border.bottom
    console.log "Dims: #{visible_width},#{visible_height}, max: #{@config.border.left + visible_width + @config.border.right},#{@config.border.top + visible_height + @config.border.bottom}"

    console.log "Canvas: #{@config.context.width()},#{@config.context.height()}"


    $('canvas').drawRect
      strokeStyle: "#B0B0B0",
      strokeWidth: 2
      x: startx, y: starty
      width: visible_width
      height: visible_height
      fromCenter: false

    i = 0
    x = startx + @config.gridsize
    while (i < visibleHorizontalCells-1)
      if x > startx+visible_width
        break
      $("canvas").drawLine
        strokeStyle: "#B0B0B0" ,
        strokeWidth: 1,
        x1: x, y1: starty,
        x2: x, y2: visible_height+starty
      x += @config.gridsize
      i++

    j = 0
    y = starty + @config.gridsize
    while (j < visibleVerticalCells-1)
      if y > starty+visible_height
        break
      $("canvas").drawLine
        strokeStyle: "#B0B0B0" ,
        strokeWidth: 1,
        x1: startx, y1: y,
        x2: startx+visible_width, y2: y

      y += @config.gridsize
      j++
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





$ ->
  # $('body').css
  #   width: window.innerWidth
  #   height: window.innerHeight

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




