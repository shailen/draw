import 'dart:html';
import 'dart:math';

class CanvasDrawer {
  CanvasElement canvas;
  CanvasRenderingContext2D ctxt;
  Rect offset;
  var lines = {};

  CanvasDrawer(this.canvas) {
    ctxt = canvas.getContext('2d');
    canvas.style.width = '100%';
    canvas.width = canvas.offsetWidth;
    canvas.style.width = '';
    ctxt.lineWidth = 12;
    ctxt.lineCap = "round";
    offset = canvas.offset;
  }

  void init() {
    canvas.onTouchStart.listen(preDraw);
    canvas.onTouchMove.listen(draw);
  }

  void preDraw(TouchEvent e) {
    e.preventDefault();
    e.touches.forEach((Touch touch) {
      var _id = touch.identifier;
      var colors  = ["red", "green", "yellow", "blue", "magenta", "orangered"];
      var random = new Random();
      var myColor = colors[random.nextInt(colors.length)];
      lines[_id] = {'x': touch.page.x - offset.left,
                   'y': touch.page.y - offset.top,
                   'color': myColor};
    });
  }

  void draw(TouchEvent e) {
    e.preventDefault();
    e.touches.forEach((touch) {
      var _id = touch.identifier;
      var moveX = touch.page.x - offset.left - lines[_id]['x'];
      var moveY = touch.page.y - offset.top - lines[_id]['y'];
      var ret = move(_id, moveX, moveY);
      lines[_id]['x'] = ret['x'];
      lines[_id]['y'] = ret['y'];
    });
  }

  move(i, changeX, changeY) {
    ctxt.strokeStyle = lines[i]['color'];
    ctxt.beginPath();
    ctxt.moveTo(lines[i]['x'], lines[i]['y']);
    ctxt.lineTo(lines[i]['x'] + changeX, lines[i]['y'] + changeY);
    ctxt.stroke();
    ctxt.closePath();
    return { 'x': lines[i]['x'] + changeX, 'y': lines[i]['y'] + changeY };
  }
}

void main() {
  var canvas = query('#example');
  CanvasDrawer drawer = new CanvasDrawer(canvas);
  drawer.init();
}