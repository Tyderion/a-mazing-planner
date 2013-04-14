
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
      cells: 10
      drawn: 0
    vertical:
      offset: 0
      cells: 5
      drawn: 0
    border:
      left: 60
      right: 100
      top: 60
      bottom: 20
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






    # console.log "Visible Width: #{visible_width} and num-cells: #{visible_width/@config.gridsize}"
    # Visible cells are either the total cells or all that can be fit into the width/height of the context
    visibleHorizontalCells =  Math.floor  Math.min   (@config.context.width()-@config.border.left-@config.border.right)/@config.gridsize-(if xoffset < 0 then 0 else xoffset)
                                          ,          @config.horizontal.cells-(if xoffset > 0 then -xoffset else  Math.abs(xoffset))
                                          ,          visible_width/@config.gridsize-(if xoffset > 0 then xoffset else 0)


    # visibleHorizontalCells = @grid.length-1 if visibleHorizontalCells >= @grid.length
    visibleVerticalCells =  Math.floor Math.min  (@config.context.height()-@config.border.top-@config.border.bottom)/@config.gridsize-(if yoffset < 0 then 0 else yoffset)
                             ,         @config.vertical.cells-(if yoffset < 0 then -yoffset else  Math.abs(yoffset))
                             ,          visible_height/@config.gridsize-(if yoffset > 0 then yoffset else 0)
    # visibleVerticalCells++
    # console.log "verticals: #{visibleVerticalCells} + offset: #{yoffset} horizontals: #{visibleHorizontalCells} + offset: #{xoffset}"
    # Save coordinates of cells in 2 lists for easy of drawing later
    xcells = []
    ycells = []

    xcells.push startx-@config.gridsize
    ycells.push starty-@config.gridsize


    i = 0
    # Compute the coordinates of the grid
    x = startx# + @config.gridsize
    while (i < visibleHorizontalCells)
      if x > @config.context.width()+100
        break
      xcells.push x if  x > -@config.gridsize
      x += @config.gridsize
      i++



    j = 0
    y = starty#+@config.gridsize
    while (j < visibleVerticalCells)
      # if y > @config.context.height()+100
      #   break
      ycells.push y if y > -@config.gridsize
      y += @config.gridsize
      j++




    # Draw the Tiles
    i = if yoffset < 0 then -yoffset else 0
    j = if xoffset < 0 then -xoffset else 0

    # relevant_xcells = xcells[(if xoffset < 0 then -xoffset else 0)..xcells.length-xoffset]
    relevant_xcells = xcells#[0..xcells.length]

    relevant_ycells = ycells#[(if yoffset < 0 then -yoffset else 0)..ycells.length-(if yoffset > 0 then yoffset else 0)]
    # console.log relevant_ycells
    # console.log xcells.length
    # console.log ycells
    for x in relevant_xcells
      for y in relevant_ycells
        # console.log "Accessing #{j+x_coord_offset}"
        # break if j >= @grid.length or i >= @grid[0].length
        @grid[j]?[i]?.draw(x,y, @config.gridsize)
        i++
      i = if yoffset < 0 then -yoffset else 0
      j++

    # xcells.push xcells[xcells.length-1]+@config.gridsize
    # ycells.push ycells[ycells.length-1]+@config.gridsize



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
        x1: x, y1: ycells[0],
        x2: x, y2: ycells[ycells.length-1]
    for y in ycells
      $("canvas").drawLine
        strokeStyle: "#B0B0B0" ,
        strokeWidth: 1,
        x1: xcells[0], y1: y,
        x2: xcells[xcells.length-1], y2: y




    # And the last step is a white border around the grid to cut off any excess rounded-rectangles.
    # Left Border
    $('canvas').drawRect
      fillStyle: "#0FF000", #ColorLuminance(@color, @color_bias),
      x: 0, y: 0
      width: startx_rec-1
      height: @config.context.height()
      fromCenter: false
      opacity: 0.5

    # Bottom Border
    $('canvas').drawRect
      fillStyle: "#F0F000", #ColorLuminance(@color, @color_bias),
      x: 0, y: starty_rec + visible_height+1
      width: @config.context.width()
      height: @config.context.height()- (starty_rec + visible_height)
      fromCenter: false
      opacity: 0.5

    # #Top Border
    $('canvas').drawRect
      fillStyle: "#FFF0F0", #ColorLuminance(@color, @color_bias),
      x: 0, y: 0
      width: @config.context.width()
      height: starty_rec-1
      fromCenter: false
      opacity: 0.5
    # Right Border
    $('canvas').drawRect
      fillStyle: "#FF0000", #ColorLuminance(@color, @color_bias),
      x: startx_rec+visible_width+1, y: 0
      width: @config.context.width()- (startx_rec + visible_width)
      height: @config.context.height()
      fromCenter: false
      opacity: 0.5



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
            @config.mouseout = event
            console.log "Clicked outside the grid"
            # mouseout = event
      mousemove: (event) =>
        if @config.mousein
          @config.horizontal.offset += (event.clientX - @config.mousein.clientX)
          @config.vertical.offset += (event.clientY - @config.mousein.clientY)
          @config.mousein = event
          @config.timout = setTimeout @draw, 20
        if @config.mouseout
          xdiff = event.clientX - @config.mouseout.clientX
          if xdiff < 0  or @config.border.left + @config.horizontal.drawn + xdiff < @config.context.width()
            @config.border.left += xdiff
          if @config.border.left+xdiff < 1
           @config.border.left = 1


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
        @config.mousein = null
        @config.mouseout = null





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




