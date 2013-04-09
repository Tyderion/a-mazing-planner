$ ->
  drawingCanvas = document.getElementById "drawing"
  window.ok = false
  # Check the element is in the DOM and the browser supports canvas
  if drawingCanvas.getContext
    $('p').remove()
    # Initaliase a 2-dimensional drawing context
    context = drawingCanvas.getContext('2d');


    width = window.innerWidth
    height = window.innerHeight

    context.canvas.width  = width;
    context.canvas.height = height;
    window.ok = true
    #Canvas commands go here
    window.gridsize = 19

    game = new  window.Game(width, height, context)
    $(window).on "resize", (event) ->
      game.redrawContext()

    $(window).on "mousewheel", (event, delta, deltaX, deltaY) ->
      if deltaY > 0
        window.gridsize += deltaY if window.gridsize < 40
      else
        window.gridsize += deltaY if window.gridsize > 5
      game.redrawContext()


