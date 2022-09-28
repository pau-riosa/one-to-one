export function sharerAnnotate(webrtcChannel) {
  const copy = (document.querySelector(
    "#screensharing-template"
  ) as HTMLTemplateElement).content.cloneNode(true) as Element;
  const feed = copy.querySelector("div[name='video-feed']") as HTMLDivElement;
  const showCanvas = feed.querySelector("#paint") as HTMLCanvasElement;
  feed.appendChild(showCanvas);
  var canvas = document.querySelector("#paint") as HTMLCanvasElement;
  var ctx = canvas.getContext("2d");
  loadCanvas(ctx, canvas, randomColor(), webrtcChannel);
}

export function viewerAnnotate(webrtcChannel) {
  const copy = (document.querySelector(
    "#screensharing-template"
  ) as HTMLTemplateElement).content.cloneNode(true) as Element;
  const feed = copy.querySelector("div[name='video-feed']") as HTMLDivElement;
  const showCanvas = feed.querySelector("#output") as HTMLCanvasElement;
  feed.appendChild(showCanvas);
  var canvas = document.querySelector("#output") as HTMLCanvasElement;
  var ctx = canvas.getContext("2d");
  loadCanvas(ctx, canvas, randomColor(), webrtcChannel);
}

export function loadCanvas(ctx, canvas, color, webrtcChannel) {
  var mouse = { x: 0, y: 0 };
  var last_mouse = { x: 0, y: 0 };

  /* Mouse Capturing Work */
  document.addEventListener("mousemove", (e) => {
    last_mouse = { x: e.offsetX, y: e.offsetY };
    mouse.x = e.pageX - this.offsetLeft;
    mouse.y = e.pageY - this.offsetTop;
  });

  /* Drawing on Paint App */

  canvas.addEventListener("mousedown", (e) => {
    canvas.addEventListener("mousemove", move, false);
  });

  canvas.addEventListener("mouseup", (e) => {
    canvas.removeEventListener("mousemove", move, false);
  });

  var move = (e) => {
    mouse = { x: e.offsetX, y: e.offsetY };

    draw(ctx, {
      last_mouse,
      x: mouse.x,
      y: mouse.y,
      color: color,
    });

    webrtcChannel.push("draw", {
      data: {
        x: mouse.x,
        y: mouse.y,
        last_mouse: last_mouse,
        color: color,
      },
    });

    webrtcChannel.on("draw", (event: any) => {
      console.log("draw data", event);
      draw(ctx, event);
    });

    last_mouse = { x: mouse.x, y: mouse.y };
  };

  var resize = () => {
    var video = document.querySelector("video[name='screenshare']");
    canvas.width = video.offsetWidth;
    canvas.height = video.offsetHeight;
  };

  window.onresize = resize;
  resize();
}

function erase(ctx, data) {
  ctx.beginPath();
  ctx.moveTo(data.last_mouse.x, data.last_mouse.y);
  ctx.lineTo(data.x, data.y);
  ctx.globalCompositeOperation = "destination-out";
  ctx.strokeStyle = data.color;
  ctx.lineWidth = 100;
  ctx.lineJoin = "round";
  ctx.lineCap = "round";
  ctx.stroke();
  ctx.closePath();
}

function draw(ctx, data) {
  ctx.beginPath();
  ctx.moveTo(data.last_mouse.x, data.last_mouse.y);
  ctx.lineTo(data.x, data.y);
  ctx.strokeStyle = data.color;
  ctx.lineWidth = 5;
  ctx.lineJoin = "round";
  ctx.lineCap = "round";
  ctx.stroke();
  ctx.closePath();
}

function randomColor() {
  let r = Math.random() * 255;
  let g = Math.random() * 255;
  let b = Math.random() * 255;
  return `rgb(${r}, ${g}, ${b})`;
}
