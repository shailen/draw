import 'dart:html';
import 'dart:async';
import 'package:web_ui/web_ui.dart';
import 'dart:collection';

@observable
String selectedThickness = 'Thin';
LinkedHashMap<String, int> thicknessMap = {'Super-thin' : 3,
                                           'Thin' : 6,
                                           'Medium': 12,
                                           'Thick' : 24,
                                           'Super-thick': 48};

@observable
String selectedColor = 'blue';
LinkedHashMap<String, int> colorsMap = {'red'    : 'rgb(180, 30, 20)',
                                        'green'  : 'rgb(30, 180, 20)',
                                        'blue'   : 'rgb(30,  20, 180)',
                                        'yellow' : 'rgb(250,250, 125)'};
class Doodle {
  CanvasElement canvas;
  CanvasRenderingContext2D ctx;
  num lastX, lastY, nextX, nextY;
  bool draw = false;
  var subscription;
  DataModel dataModel;

  Doodle(this.canvas) {
    setCanvasSize();
    ctx = canvas.getContext('2d');
    ctx.lineWidth = thicknessMap[selectedThickness];
    ctx.lineCap = 'round';
    ctx.strokeStyle = colorsMap[selectedColor];
    dataModel = new DataModel();
    clearCanvas();
    window.animationFrame.then(frame);
  }

  void frame(num t) {
    window.animationFrame.then(frame);
    drawEverything();
  }

  num windowToCanvas(x) {
    var bbox = canvas.getBoundingClientRect();
    return x - bbox.left * (canvas.width / bbox.width);
  }

  void setCanvasSize([Event e]) {
    canvas.width = document.body.offsetWidth;
    canvas.height = (document.body.offsetHeight * .85).toInt();
  }

  void begin() {
    window.onResize.listen(setCanvasSize);
    canvas.onMouseDown.listen(mouseClickCallback);
    canvas.onTouchStart.listen(touchStart);
  }
  
  void mouseClickCallback(MouseEvent e) {
      e.preventDefault();
      e.stopPropagation();

      lastX = nextX = windowToCanvas(e.client.x);
      lastY = nextY = windowToCanvas(e.client.y);

      subscription = canvas.onMouseMove.listen(mouseMoveCallback);
      canvas.onMouseUp.listen(mouseUpCallback);
      draw = true;
      dataModel.paths.add(new PathData(lastX, lastY, nextX, nextY,
          ctx.strokeStyle, ctx.lineWidth, true));
  }
  
  void touchStart(TouchEvent e) {
    e.preventDefault();
    e.stopPropagation();

    lastX = nextX = windowToCanvas(e.layer.x);
    lastY = nextY = windowToCanvas(e.layer.y);

    subscription = canvas.onTouchMove.listen(touchMove);
    canvas.onTouchEnd.listen(touchEnd);
    draw = true;
    dataModel.paths.add(new PathData(lastX, lastY, nextX, nextY,
        ctx.strokeStyle, ctx.lineWidth, true));
  }
  
  void mouseMoveCallback(MouseEvent e) {
    e.preventDefault();
    e.stopPropagation();
    nextX = windowToCanvas(e.client.x);
    nextY = windowToCanvas(e.client.y);
    ctx.lineWidth = thicknessMap[selectedThickness];
    ctx.strokeStyle = colorsMap[selectedColor];

    dataModel.paths.add(new PathData(lastX, lastY, nextX, nextY,
        ctx.strokeStyle, ctx.lineWidth));
  }

  void touchMove(TouchEvent e) {
    e.preventDefault();
    e.stopPropagation();
    nextX = windowToCanvas(e.layer.x);
    nextY = windowToCanvas(e.layer.y);
    ctx.lineWidth = thicknessMap[selectedThickness];
    ctx.strokeStyle = colorsMap[selectedColor];

    dataModel.paths.add(new PathData(lastX, lastY, nextX, nextY,
        ctx.strokeStyle, ctx.lineWidth));
  }
  
  void mouseUpCallback(MouseEvent e) {
    e.preventDefault();
    e.stopPropagation();
    subscription.cancel();
    draw = false;
  }

  void touchEnd(TouchEvent e) {
    e.preventDefault();
    e.stopPropagation();
    subscription.cancel();
    draw = false;
  }
  
  clearCanvas() {
    ctx.fillStyle = '#EEE';
    ctx.fillRect(0, 0, canvas.width, canvas.height);
  }

  drawLine() {
    if (!draw) return;
    _drawLine(lastX, lastY, nextX, nextY);

    lastX = nextX;
    lastY = nextY;
  }

  drawEverything() {
    draw = true;
    clearCanvas();
    ctx.lineWidth = thicknessMap[selectedThickness];
    ctx.strokeStyle = colorsMap[selectedColor];

    for (var i = 0; i < dataModel.paths.length; i++) {
      ctx.lineWidth = dataModel.paths[i].lineWidth;
      ctx.strokeStyle = dataModel.paths[i].strokeStyle;
      _drawLine(dataModel.paths[i].lastX,
                dataModel.paths[i].lastY,
                dataModel.paths[i].nextX,
                dataModel.paths[i].nextY);
      lastX = nextX;
      lastY = nextY;
    }
    draw = false;
  }

  _drawLine(lastX, lastY, nextX, nextY) {
    ctx.beginPath();
    ctx.moveTo(lastX, lastY);
    ctx.lineTo(nextX, nextY);
    ctx.stroke();
    ctx.closePath();
  }

}

class DataModel {
  List<PathData> paths = [];
}

class PathData {
  num lastX, lastY, nextX, nextY;
  String strokeStyle;
  num lineWidth;
  bool onMouseDown;

  PathData(this.lastX, this.lastY, this.nextX, this.nextY,
       this.strokeStyle, this.lineWidth, [this.onMouseDown = false]);

  String toString() => '[$lastX, $lastY, $nextX, $nextY, $strokeStyle, $lineWidth, $onMouseDown]';
}

void main() {
  CanvasElement canvas = query('canvas');
  
  var doodle = new Doodle(canvas);
  
  doodle.begin();
  query('#undo-last-doodle').onClick.listen((event) {
    event.preventDefault();
    event.stopPropagation();

    if (doodle.dataModel.paths.isEmpty) return;
    var lastItem = doodle.dataModel.paths.lastWhere((item) => item.onMouseDown == true);
    var lastIndex = doodle.dataModel.paths.indexOf(lastItem);
    doodle.dataModel.paths = doodle.dataModel.paths.getRange(0, lastIndex).toList();
    doodle.drawEverything();
  });
}
