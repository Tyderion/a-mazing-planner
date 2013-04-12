$ ->
  $('#start').on
    click: ->
      start()

  start = ->
    drawingCanvas = document.getElementById "drawing"
    window.ok = false
    # Check the element is in the DOM and the browser supports canvas
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

      console.log params
      # width = window.innerWidth
      # height = window.innerHeight

      # context.canvas.width  = width;
      # context.canvas.height = height;
      window.ok = true
      #Canvas commands go here
      window.gridsize = 50#20

      # if $.cookie('test') != ""
      #   str = $.cookie('test')
      #   console.log "Loaded cookie: #{str}"
      # else
      #   str = ""
      # console.log "Gridsize: #{window.gridsize

      string = ""
      string = params.string if params.string
      game = new  window.Game(context,$('#heightslider').get(0).value,$('#widthslider').get(0).value, string)



  start()
