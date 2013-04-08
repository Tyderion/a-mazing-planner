// Generated by CoffeeScript 1.6.2
(function() {
  var checkDims, drawGrid, redrawContext;

  $(function() {
    var context, drawingCanvas, height, steps, width;

    drawingCanvas = document.getElementById("drawing");
    if (drawingCanvas.getContext) {
      $('p').remove();
      context = drawingCanvas.getContext('2d');
      $(window).on("resize", function(event) {
        return redrawContext(context);
      });
      $(window).on("mousewheel", function(event, delta, deltaX, deltaY) {
        if (deltaY > 0) {
          if (window.gridsize < 40) {
            window.gridsize += deltaY;
          }
        } else {
          if (window.gridsize > 5) {
            window.gridsize += deltaY;
          }
        }
        return redrawContext(context);
      });
      width = window.innerWidth;
      height = window.innerHeight;
      context.canvas.width = width;
      context.canvas.height = height;
      $("canvas").drawArc({
        fillStyle: "black",
        x: 100,
        y: 100,
        radius: 50
      });
      window.gridsize = 19;
      steps = width / window.gridsize;
      return drawGrid(0, 0, width, height, steps);
    }
  });

  redrawContext = function(context) {
    var height, steps, width;

    $("canvas").clearCanvas();
    width = window.innerWidth;
    height = window.innerHeight;
    steps = width / window.gridsize;
    context.canvas.width = width;
    context.canvas.height = height;
    return drawGrid(0, 0, width, height, steps);
  };

  checkDims = function() {
    var height, width;

    global(height, width);
    if (width !== window.innerWidth) {
      width = window.innerWidth;
    }
    if (height !== window.innerheight) {
      return height = window.innerHeight;
    }
  };

  drawGrid = function(x, y, width, height, steps) {
    var i, j, vertsteps, _results;

    vertsteps = (height / width) * steps;
    $('canvas').drawRect({
      layer: true,
      name: "border",
      group: "grid",
      strokeStyle: "#000",
      strokeWidth: 2,
      x: x,
      y: y,
      width: width,
      height: height,
      fromCenter: false
    });
    i = 0;
    while (i < width) {
      $("canvas").drawLine({
        layer: true,
        name: "vline" + i,
        group: "grid",
        strokeStyle: "#B0B0B0",
        strokeWidth: 1,
        x1: i,
        y1: 0,
        x2: i,
        y2: height
      });
      i += width / steps;
    }
    j = 0;
    _results = [];
    while (j < height) {
      $("canvas").drawLine({
        layer: true,
        name: "hline" + j,
        group: "grid",
        strokeStyle: "#B0B0B0",
        strokeWidth: 1,
        x1: 0,
        y1: j,
        x2: width,
        y2: j
      });
      _results.push(j += height / vertsteps);
    }
    return _results;
  };

}).call(this);
