
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
      cells: 100
    vertical:
      offset: 0
      cells: 100
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
    visibleHorizontalCells = @config.context.width/@config.gridsize
    visibleHorizontalCells = (@config.context.width/@config.context.height)*@config.gridsize
    startx = @config.border.left
    starty = @config.border.top
    if @config.horizontal.offset < 0
      visible_width = @config.horizontal.length() + @config.horizontal.offset
    else
      startx += @config.horizontal.offset
      visible_width = Math.min @config.horizontal.length(), @config.context.width()

    if @config.vertical.offset < 0
      visible_height = @config.vertical.length() + @config.vertical.offset
    else
      starty += @config.vertical.offset
      visible_height = Math.min @config.vertical.length(), @config.context.height()

    console.log "Start: #{startx},#{starty}, Dims: #{visible_width},#{visible_height}"

    console.log "Canvas: #{@config.context.width()},#{@config.context.height()}"


    $('canvas').drawRect
      strokeStyle: "#000",
      strokeWidth: 2
      x: startx, y: starty
      width: visible_width - @config.border.right-1
      height: visible_height -  @config.border.bottom-1
      fromCenter: false

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

  createHandlers: ->
    $('#save').on
      click: (e) =>
        $('#settings').hide()
        @draw()






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



