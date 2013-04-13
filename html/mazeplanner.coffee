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
          x: x+width/2
          y: y+height/2
          font: "#{window.gridsize/3*2}pt Verdana, sans-serif"
          text: "#{@num}"



class Overlay

  constructor: (game) ->
    @x = 0
    @y = 0
    @game = game
    @redraw = false
    @timout = 0



  draw: (x,y ,xoffset, yoffset, rec_width, rec_height, fake, width=2, height=2) ->
    if fake
      # x = Math.floor( Math.max(e.clientX-10-xoffset,0) / window.gridsize)
      # y = Math.floor( Math.max(e.clientY-10-yoffset,0) / window.gridsize)
      # console.log "Coordinates: (#{e.clientX},#{e.clientY}) and cell: (#{x},#{y}) with value: #{grid[x][y].type}"
      fake = new Obstacle(x,y,width, height,4)
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


class window.Game
  @game
  @BLOCKED = 99
  @it: ->
    return @game



  constructor: (context, cellsX, cellsY, string) -> #, xoffset = 100, yoffset = 100) ->
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
    @xoffset = 100#xoffset
    @yoffset = 100#yoffset

    @hidecursor = true

    @overlay = true
    @animate = false

    @lastdown = 0

    @hasmoved = []
    @cookiename = "maze"
    @cookieoptions = { path: '/' }
    @path = []

    @redrawn = false

    @theOverlay = new Overlay(this)


    @checkDims()
    @string = string
    @grid = for row in [0..@cellsX]
      	for col in [0..@cellsY]
             new Obstacle(row, col, 1,1)
    @createhandlers()
    @dosave = true
    if string != ""
      @load(string)
      @dosave = false
    else
      @load($.cookie(@cookiename))
    # @redrawContext()
    $('#start').remove()

  adjustSize: (height, width)->
    grid = @grid
    @cellsX = width
    @cellsY = height
    # console.log "Grid dimensions: #{grid.length} x #{grid[0].length}"
    @grid = for row in [0..@cellsX]
        for col in [0..@cellsY]
          if grid[row]?[col] is undefined
             new Obstacle(row, col, 1,1)
          else
            width = grid[row][col].width
            height = grid[row][col].height
            # console.log "#{col}+#{height} > #{@cellsY} or #{row}+#{width} > #{@cellsX}"
            if col+height-1 > @cellsY or row+width-1 > @cellsX
              new Obstacle(row, col, 1,1)
            else
              new Obstacle(row, col, width ,  height, grid[row][col].type, grid[row][col].num)


  reset: ->
    jConfirm "Do you really want to reset the Maze?", "Confirmation Dialog", (r) =>
      if r
        $.removeCookie @cookiename#, @cookieoptions
        @grid = for row in [0..@cellsX]
          for col in [0..@cellsY]
            new Obstacle(row, col, 1,1,0)
        @xoffset = 100
        @yoffset = 100
        @path = []
        @redrawContext()


  save: (override = false)->
    if override or @dosave
      @removePath()
      @createString()
      $.cookie @cookiename, @string, @cookieoptions

  load: (string)->
    @string = string

    # console.log "String is (loading): #{@string}"
    if @string
      @readString()
    else
      jAlert "Press 'o' to open the options menu", "Alert Dialog"

    @createString()
    # console.log "String is: #{@string}"
    @redrawContext()
    # @debug()


  readString: ->
    if @string
      strings = @string.split(/;/)
      index = 0
      for obstacle in strings
        unless obstacle is ""
          attrs = obstacle.split(/,/)
          attrs = (parseInt(ele) for ele in attrs)
          if index is 0
            # console.log "Setting offset: #{attrs[0]},#{attrs[1]} and size #{attrs[2]},#{attrs[3]}"
            @xoffset = attrs[0]
            @yoffset = attrs[1]

            @cellsX = attrs[2]

            @cellsY = attrs[3]
            window.gridsize = attrs[4]
            @grid = for row in [0..@cellsX]
              for col in [0..@cellsY]
                new Obstacle(row, col, 1,1,0)
            index++
          else
            [x, y, width, height, type,num] = attrs
            # console.log "Creating obstacle: #{x}, #{y}, #{width}, #{height}, #{type},#{num}"
            if type is 3
              @path[num] = [x,y]
            if type is 1
              for i in [0..height-1]
                for j in [0..width-1]
                  @grid[x+j][y+i] = new Obstacle(x+j,y+i, width, height, @constructor.BLOCKED, num)
            @grid[x][y] = new Obstacle(x,y, width, height, type, num) unless type is @constructor.BLOCKED
      # console.log "Parsed #{numobstacles} Obstacles and #{numblocked} Blocked cells"
      # @debug()

  createString: ->
    @string = "#{@xoffset},#{@yoffset},#{@cellsX},#{@cellsY},#{window.gridsize};"
    # console.log "Saving offset: #{@string}"
    for i in [0..@cellsX]
      for j in [0..@cellsY]
        ele = @grid[i][j]

        # console.log "Tower-Type: #{ele.type}"
        # If it is a tower, save it
        if (ele.type >= 1)
          # cellx, celly, width, height, type
          num = ""
          if ele.type == 3
            index = 0
            # console.log @path
            for coords in @path
              if coords[0] == i and coords[1] == j
                num = ",#{index}"
              index++
            # console.log "Searching: [#{i},#{j}] in the path"
            # console.log "Path number: #{num}"
          # console.log "Number is: #{num}!"
          unless ele.type is @constructor.BLOCKED
            # console.log "Saving element: #{i},#{j},#{ele.width},#{ele.height},#{ele.type}#{num};"
            @string += "#{i},#{j},#{ele.width},#{ele.height},#{ele.type}#{num};"
    # console.log "Saved all elements in string: #{@string}"

  debug: ->
    string = ""
    for i in [0..@grid[0].length-1]
      for j in [0..@grid.length-1]
        type  = @grid[j][i].type
        if type
          string = "#{string}#{if type > 10 then ' ' else '  '}#{type}"
        else
          string = "#{string}  0"
      string = "#{string}\n"
    string = "#{string}\n\n"
    # console.log string
    # @createString()
    # console.log @string.split /;/

  redrawContext:  =>
    $("canvas").clearCanvas()
    @checkDims()
    @context.canvas.width  = @width;
    @context.canvas.height = @height;
    @drawGrid(@xoffset, @yoffset)
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
    else if current is 0 or current is 3
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
    #TODO: Streamline this function
    # console.log event
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
        else if event.altKey
          @obstacle_height = @obstacle_width = 3
        else
          @getConfig()

          # console.log "Width is: #{@obstacle_width}"

        ele = @grid[x][y]
        # console.log ele
        # Unblock stuff that tower blocked
        # console.log "element height: #{ele.height} and new height: #{@obstacle_height}"
        if ele.width > @obstacle_width or ele.height > @obstacle_height
         for i in [0..ele.height-1]
          for j in [0..ele.width-1]
            # console.log "{i}{j} = #{i},#{j}"
            # if i is 0 and j is 0######
            @grid[x+j][y+i].type = 0
            # console.log "resetting: #{x+j},#{y+i} from #{@grid[x+j][y+i].type} to #{@grid[x+j][y+i].type*-1 + @constructor.BLOCKED}"

        # console.log "obstacle size:  #{@obstacle_width}x#{@obstacle_height}"
        if @checkValidity(x,y)
          @grid[x][y] = new Obstacle(x,y,@obstacle_width, @obstacle_height, newval, if newval is 3 then @path.length-1 else undefined )
          # unless current is 1
          for i in [0..@obstacle_height-1]
            for j in [0..@obstacle_width-1]
              unless i is 0 and j is 0
                if current is 1
                  @grid[x+j][y+i].type = 0
                else
                  @grid[x+j][y+i].type = @constructor.BLOCKED
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
        _result = []
        start = graph.nodes[@path[index_start][0]][@path[index_start][1]]
        end = graph.nodes[@path[index_start+1][0]][@path[index_start+1][1]]
        # console.log "Calculating path from #{index_start} to #{index_start+1}"§
        _result = astar.search(graph.nodes, start, end)
        distance = (Math.abs(start.x-end.x)+Math.abs(start.y-end.y))
        # console.log "Iteration: #{index_start} Result length: #{_result.length} and distance is : #{distance}"
        if _result.length < 1 and distance > 1
          # console.log "index is #{index_start} and we're stopping the calculation"
          break
        else
          result.push node for node in _result
        index_start++


      # if result.length > 0
        # result.push(graph.nodes[@path[@path.length-1][0]][@path[@path.length-1][1]])
      result.unshift(graph.nodes[@path[0][0]][@path[0][1]])



      # @animatePath(0, result)
      if @animate
        #jAlert "Path Calculated", "Alert Dialog"
        @animatePath(0, result)
      else
        @instantPath(result)
        jAlert "Your Maze is #{result.length} Tiles long.", "Alert Dialog"



  instantPath:(result) ->
    index = 0
    while (index < result.length-1)
      x = result[index].x
      y = result[index].y
      element = @grid[x][y]
      if element.type is 5
        factor = -0.2
        bias = if element.color_bias in [undefined, 0] then -1 else element.color_bias
        adjusted = bias*factor
        adjusted*=-1 if adjusted > 0

        # console.log "element-bias is  #{bias} and factor is : #{factor} and adjusted is #{adjusted}"
        element.adjustBias(adjusted)
        # console.log "element-bias is  #{element.bias}"


      else if element.type == 3
        @grid[x][y] = new Obstacle(x, y, 1, 1, 5, element.num)
      else
        @grid[x][y] = new Obstacle(x, y, 1, 1, 5)
      if index is result.length-1
        jAlert "Your Maze is #{result.length} Tiles long.", "Alert Dialog"
      index++
    @redrawContext()

  animatePath: (index, result) ->
    window.setTimeout =>
      x = result[index].x
      y = result[index].y
      element = @grid[x][y]
      if element.type is 5
        factor = -0.2
        bias = if element.color_bias in [undefined, 0] then -1 else element.color_bias
        adjusted = bias*factor
        adjusted*=-1 if adjusted > 0

        # console.log "element-bias is  #{bias} and factor is : #{factor} and adjusted is #{adjusted}"
        element.adjustBias(adjusted)
        # console.log "element-bias is  #{element.bias}"


      else if element.type == 3
        @grid[x][y] = new Obstacle(x, y, 1, 1, 5, element.num)
      else
        @grid[x][y] = new Obstacle(x, y, 1, 1, 5)
      @redrawContext()
      if index is result.length-1
        jAlert "Your Maze is #{result.length} Tiles long.", "Alert Dialog"
      else
        @animatePath(index+1, result)

    , 3#window.gridsize/10



# result is an array containing the shortest path




  drawGrid: (x,y) ->
    steps = @width/window.gridsize
    vertsteps = (@height/@width)*steps
    @rec_width = Math.min (@width/steps)*(@cellsX+1), @width-@xoffset-1
    @rec_height = Math.min (@height/vertsteps)*(@cellsY+1), @height-@yoffset-1
    if x < 0
      recx =  1
      recwidth = @rec_width + x
      # console.log "X is : #{x} and width: #{@rec_width} "
      # @rec_width += x
    else
      recx = x
      recwidth = @rec_width
    if y < 0
      recy =  1
      recheight = @rec_height + y
      # @rec_height += y
    else
      recy = y
      recheight = @rec_height
    $('canvas').drawRect
      layer: true
      name: "border"
      group: "grid"
      strokeStyle: "#000",
      strokeWidth: 2
      x: recx, y: recy
      width: recwidth
      height: recheight
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

    for x in [0..@cellsX]
      for y in [0..@cellsY]
        @grid[x][y].draw(@xoffset, @yoffset)

  toggleMenu: ->
    $('#settings').toggle()
    $('#grid_height').get(0).value = @cellsY
    $('#current_grid_height').html @cellsY+1
    $('#grid_width').get(0).value = @cellsX
    $('#current_grid_width').html @cellsX+1
    $('#overlay_chk').attr('checked', @overlay)
    $('#instant_draw_chk').attr('checked', not @animate)
    $('#tower_height').get(0).value = @obstacle_height
    $('#current_tower_height').html @obstacle_height
    $('#tower_width').get(0).value = @obstacle_width
    $('#current_tower_width').html @obstacle_width
    $('#hide_cursor_chk').attr('checked', @hidecursor)

  getConfig: ->
      @obstacle_height = parseInt $('#tower_height').get('0').value
      @obstacle_width = parseInt $('#tower_width').get('0').value




  createhandlers: ->

    $("#drawing").on
      mousemove: (e) =>
        x = Math.floor( Math.max(e.clientX-10-@xoffset,0) / window.gridsize)
        y = Math.floor( Math.max(e.clientY-10-@yoffset,0) / window.gridsize)
        if @overlay
          if e.shiftKey
            @obstacle_height = @obstacle_width = 1
          else if e.altKey
            @obstacle_height = @obstacle_width = 3
          inx = e.clientX in [@xoffset..@rec_width+@xoffset]
          iny = e.clientY in [@yoffset..@rec_height+@yoffset]
          if inx and iny
            if @hidecursor
              $("#drawing").css('cursor', "none")
            else
              $("#drawing").css('cursor', 'default')

            if @checkValidity(x,y)
              @theOverlay.draw(x,y, @xoffset, @yoffset, @rec_width, @rec_height, true, @obstacle_width, @obstacle_height )
          else
            @theOverlay.draw(x,y, @xoffset, @yoffset, @rec_width, @rec_height, false, @obstacle_width, @obstacle_height)
            $("#drawing").css('cursor', 'default')
          @getConfig()


        if @mousedown
          $("#drawing").css('cursor', 'pointer')
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
          @hasmoved = [x,y]
          # Save new position
          @mousedown = e
      mousedown: (e) =>
        @mousedown = e
        @lastdown = new Date().getTime()
      mouseup: (e) =>
        @mousedown = null
        # xdiff = Math.abs @hasmoved.clientX - e.clientX
        # ydiff = Math.abs @hasmoved.clientY - e.clientY
        # console.log "Move-distance: #{xdiff},#{ydiff}"

        x = Math.floor( Math.max(e.clientX-10-@xoffset,0) / window.gridsize)
        y = Math.floor( Math.max(e.clientY-10-@yoffset,0) / window.gridsize)
        unless @hasmoved.length == 2 and x is @hasmoved[0] and y is @hasmoved[1]
          if e.button == 0
            @click(e)
        @hasmoved = []
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
    $('#popup_container').on
      click: (e) =>
        e.stopPropagation()
    $('#settings').on
      change: (e) =>
        id = $(e.currentTarget).attr 'id'
        $("#current_#{id}").html (parseInt($(e.currentTarget).get(0).value)+ if id.match(/grid*/) then 1 else 0)
      mousemove: (e) =>
        e.stopPropagation()
    , "[type='range']"
    $('#save').on
      click: =>
        # console.log "Clicked on save"
        @debug()
        @adjustSize(parseInt($("#grid_height").get(0).value), parseInt($("#grid_width").get(0).value))
        # console.log "after adjustsize "
        @debug()
        @overlay = if $('#overlay_chk').is(':checked') then true else false
        @animate = if $('#instant_draw_chk').is(':checked') then false else true
        @hidecursor = if $('#hide_cursor_chk').is(':checked') then true else false
        # console.log "Overlay is #{@overlay}"
        # this = new Game(@context, @celllX, @cellsY, @string, @xoffset, @yoffset)

        @redrawContext()

        @save(true)
    $('html').on
       keypress: (e) =>
        # console.log e
        if e.keyCode is 27 # Escape
          @toggleMenu()
        if e.shiftKey
          switch String.fromCharCode(e.charCode)
            when "C"
              @removePath()
        unless e.metaKey or e.shiftKey or e.altKey or e.ctrlKey
          switch String.fromCharCode(e.charCode)
            when "o"
              @toggleMenu()
            when "r"
              @reset()
            when "c"
              @calculatePath()
            when "l"
              jPrompt "Paste the save string", "", "Prompt Dialog", (r) =>
                @load(r)
                @redrawContext()
            when "s"
              jPrompt "Copy this string and give it to a friend who wants to see your maze", @string, "Prompt Dialog", (r) ->
            when "u"
              jPrompt "This is a Link to your Maze", "http://mazeplanner.is-a-geek.ch?string=#{@string}", "Prompt Dialog", (r) ->
