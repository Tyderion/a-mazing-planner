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
#= require Overlay
class Maze

  constructor: ->


