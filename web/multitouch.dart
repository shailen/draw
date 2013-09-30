import 'dart:html';

class Doodle {
  CanvasElement canvas;
  CanvasRenderingContext2D ctxt;
  Rect offset;
  int lastX, lastY, nextX, nextY;
  bool drawing = false;
  var subscription;

  Doodle(this.canvas) {
    ctxt = canvas.getContext('2d');
    canvas.style.width = '100%';
    canvas.width = canvas.offsetWidth;
    ctxt.lineWidth = 12;
    ctxt.lineCap = "round";
    offset = canvas.offset;
    ctxt.strokeStyle = 'orange';
  }

  void start() {
    canvas.onTouchStart.listen(touchStart);
    canvas.onMouseDown.listen(mouseDown);
  }

  void mouseDown(MouseEvent e) {
    e.preventDefault();
    e.stopPropagation();

    lastX = nextX = e.client.x - offset.left;
    lastY = nextY = e.client.y - offset.top;

    subscription = canvas.onMouseMove.listen(mouseMove);
    canvas.onMouseUp.listen(stopDrawing);
    drawing = true;
    drawLine();
  }

  void touchStart(TouchEvent e) {
    e.preventDefault();
    e.stopPropagation();

    e.touches.forEach((touch) {
      lastX = nextX = touch.page.x - offset.left;
      lastY = nextY = touch.page.y - offset.top;
    });

    subscription = canvas.onTouchMove.listen(touchMove);
    canvas.onTouchEnd.listen(stopDrawing);
    drawing = true;
    drawLine();
  }

  void mouseMove(MouseEvent e) {
    e.preventDefault();
    e.stopPropagation();
    nextX = e.client.x - offset.left;
    nextY = e.client.y - offset.top;
    drawLine();
  }

  void touchMove(TouchEvent e) {
    e.preventDefault();
    e.stopPropagation();

    e.touches.forEach((touch) {
      nextX = touch.page.x - offset.left;
      nextY = touch.page.y - offset.top;
      drawLine();
    });
  }

  void stopDrawing(Event e) {
    e.preventDefault();
    e.stopPropagation();
    subscription.cancel();
    drawing = false;
  }

  void drawLine() {
    if (!drawing) return;

    ctxt.beginPath();
    ctxt.moveTo(lastX, lastY);
    ctxt.lineTo(nextX, nextY);
    ctxt.stroke();
    ctxt.closePath();

    lastX = nextX;
    lastY = nextY;
  }
}

void main() {
  var canvas = query('#example');
  Doodle drawer = new Doodle(canvas);
  drawer.start();
}
