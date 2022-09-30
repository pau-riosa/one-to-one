let tool = "draw";

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
  pen();
  eraser();
  clearAll(webrtcChannel);
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
  pen();
  eraser();
  clearAll(webrtcChannel);
}

function pen() {
  let pen = document.querySelector("#pen");
  pen.addEventListener("click", () => {
    tool = "draw";
  });
}

function eraser() {
  let eraser = document.querySelector("#eraser");
  eraser.addEventListener("click", () => {
    tool = "erase";
  });
}

function clearAll(webrtcChannel) {
  let clearAll = document.querySelector("#clear-all");
  clearAll.addEventListener("click", () => {
    var canvas1 = document.querySelector("#paint") as HTMLCanvasElement;
    var ctx1 = canvas1.getContext("2d");

    var canvas2 = document.querySelector("#output") as HTMLCanvasElement;
    var ctx2 = canvas2.getContext("2d");
    webrtcChannel.push("clear_all", { data: { clear: true } });

    webrtcChannel.on("clear_all", (event: any) => {
      ctx1.clearRect(0, 0, canvas1.width, canvas1.height);
      ctx2.clearRect(0, 0, canvas2.width, canvas2.height);
    });
  });
}

function loadCanvas(ctx, canvas, color, webrtcChannel) {
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

    if (tool === "draw") {
      startDraw(ctx, last_mouse, mouse, color, webrtcChannel);
    }

    if (tool === "erase") {
      startErase(ctx, last_mouse, mouse, color, webrtcChannel);
    }

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

function startErase(ctx, last_mouse, mouse, color, webrtcChannel) {
  var canvas = document.querySelector("#paint") as HTMLCanvasElement;
  var ctx1 = canvas.getContext("2d");

  var canvas = document.querySelector("#output") as HTMLCanvasElement;
  var ctx2 = canvas.getContext("2d");

  erase(ctx1, {
    last_mouse,
    x: mouse.x,
    y: mouse.y,
  });

  erase(ctx2, {
    last_mouse,
    x: mouse.x,
    y: mouse.y,
  });

  webrtcChannel.push("erase", {
    data: {
      x: mouse.x,
      y: mouse.y,
      last_mouse: last_mouse,
      color: color,
    },
  });

  webrtcChannel.on("erase", (event: any) => {
    erase(ctx1, event);
    erase(ctx2, event);
  });
}

function startDraw(ctx, last_mouse, mouse, color, webrtcChannel) {
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

  webrtcChannel.on("draw", (event: any) => draw(ctx, event));
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
  ctx.globalCompositeOperation = "source-over";
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
