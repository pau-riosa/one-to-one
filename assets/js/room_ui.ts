const audioButton = document.getElementById("mic-control") as HTMLButtonElement;
const videoButton = document.getElementById(
  "camera-control"
) as HTMLButtonElement;
const screensharingButton = document.getElementById(
  "screensharing-control"
) as HTMLButtonElement;
const leaveButton = document.getElementById(
  "leave-control"
) as HTMLButtonElement;

type State = { isLocalScreensharingOn: boolean };

// set of local streams used to control local user's streams
let localStreams: MediaStreams | null;
let state: State = { isLocalScreensharingOn: false };

interface SetupCallbacks {
  onLeave: () => void;
  onScreensharingStart: () => Promise<void>;
  onScreensharingEnd: () => Promise<void>;
}

type MediaStreams = {
  audioStream: MediaStream | null;
  videoStream: MediaStream | null;
};

export function addAudioStatusChangedCallback(
  callback: (status: boolean) => any
) {
  audioButton.addEventListener("click", () =>
    callback(!getAudioButtonStatus())
  );
}

export function addVideoStatusChangedCallback(
  callback: (status: boolean) => any
) {
  videoButton.addEventListener("click", () =>
    callback(!getVideoButtonStatus())
  );
}

export function setMicIndicator(peer_id: string, active: boolean) {
  let image = document.querySelector(`#feed-${peer_id} img`);

  if (active) {
    image?.classList.add("invisible");
  } else {
    image?.classList.remove("invisible");
  }
}

export function setCameraIndicator(peer_id: string, active: boolean) {
  let text = document.querySelector(
    `#feed-${peer_id} div[name='no-video-msg']`
  );

  if (active) {
    text?.classList.add("invisible");
  } else {
    text?.classList.remove("invisible");
  }
}

export function getAudioButtonStatus(): boolean {
  return audioButton.dataset.enabled === "true";
}

export function getVideoButtonStatus(): boolean {
  return videoButton.dataset.enabled === "true";
}

export function setupControls(
  mediaStreams: MediaStreams,
  callbacks: SetupCallbacks
) {
  localStreams = mediaStreams;
  audioButton.dataset.enabled = "true";
  videoButton.dataset.enabled = "true";

  const isAudioAvailable =
    (mediaStreams.audioStream?.getAudioTracks()?.length || 0) > 0;
  const isVideoAvailable =
    (mediaStreams.videoStream?.getVideoTracks()?.length || 0) > 0;

  audioButton.addEventListener("click", toggleAudio);
  audioButton.disabled = !isAudioAvailable;
  audioButton.querySelector("img")!.src = iconFor("audio", isAudioAvailable);

  videoButton.addEventListener("click", toggleVideo);
  videoButton.disabled = !isVideoAvailable;
  videoButton.querySelector("img")!.src = iconFor("video", isVideoAvailable);

  screensharingButton.disabled = false;
  screensharingButton.onclick = toggleScreensharing(
    callbacks.onScreensharingStart,
    callbacks.onScreensharingEnd
  );

  leaveButton.onclick = () => {
    callbacks.onLeave();
  };
}

function iconFor(type: "audio" | "video", enabled: boolean): string {
  if (type === "audio") {
    return !enabled ? "/svg/mic-off-fill.svg" : "/svg/mic-line.svg";
  } else if (type === "video") {
    return !enabled ? "/svg/camera-off-line.svg" : "/svg/camera-line.svg";
  }
  return "";
}

function toggleAudio() {
  if (!localStreams?.audioStream) return;

  const icon = audioButton.querySelector("img")!;
  const enabled = audioButton.dataset.enabled === "true";

  icon.src = iconFor("audio", !enabled);
  audioButton.dataset.enabled = enabled ? "false" : "true";

  localStreams.audioStream
    .getAudioTracks()
    .forEach((track) => (track.enabled = !track.enabled));
}

function toggleVideo() {
  if (!localStreams?.videoStream) return;

  const icon = videoButton.querySelector("img")!;
  const enabled = videoButton.dataset.enabled === "true";

  icon.src = iconFor("video", !enabled);
  videoButton.dataset.enabled = enabled ? "false" : "true";

  localStreams.videoStream
    ?.getVideoTracks()
    .forEach((track) => (track.enabled = !track.enabled));
}

export function toggleScreensharing(
  onStart: (() => Promise<void>) | null,
  onEnd: (() => Promise<void>) | null
) {
  return async () => {
    try {
      if (state.isLocalScreensharingOn) {
        if (onEnd !== null) await onEnd();
        screensharingButton.classList.remove("animate-pulse");
      } else {
        if (onStart !== null) await onStart();
        screensharingButton.classList.add("animate-pulse");
      }

      state.isLocalScreensharingOn = !state.isLocalScreensharingOn;
    } catch (error) {
      console.error(error);
    }
  };
}

export function terminateScreensharing() {
  if (!state.isLocalScreensharingOn) return;

  state.isLocalScreensharingOn = !state.isLocalScreensharingOn;
}

export function getRoomId(): string {
  return document.getElementById("room")!.dataset.roomId!;
}

export function getDisplayName(): string {
  return document.getElementById("room")!.dataset.displayName!;
}

function elementId(
  peerId: string,
  type: "video" | "audio" | "feed" | "screensharing"
) {
  return `${type}-${peerId}`;
}

export function attachStream(peerId: string, streams: MediaStreams): void {
  const audioId = elementId(peerId, "audio");
  const videoId = elementId(peerId, "video");

  const { audioStream, videoStream } = streams;

  let audio = document.getElementById(audioId) as HTMLAudioElement;
  let video = document.getElementById(videoId) as HTMLVideoElement;

  audio.srcObject = audioStream;
  video.srcObject = videoStream;
}

export function attachScreensharing(
  peerId: string,
  label: string,
  stream: MediaStream
) {
  const screensharingId = elementId(peerId, "screensharing");

  let video = document.getElementById(
    screensharingId
  ) as HTMLVideoElement | null;

  if (!video) {
    video = setupScreensharing(peerId, label);
  }

  video.id = screensharingId;
  video.autoplay = true;
  video.playsInline = true;
  video.muted = false;

  video.srcObject = stream;

  adjustScreensharingGridStyles();
}

export function detachScreensharing(peerId: string) {
  document.getElementById(elementId(peerId, "screensharing"))?.remove();
  adjustScreensharingGridStyles();
}

function adjustScreensharingGridStyles() {
  const screensharingsGrid = document.getElementById("screensharings-grid")!;
  const videosGrid = document.getElementById("videos-grid")!;

  // reset styles
  screensharingsGrid.classList.remove(
    "active-screensharing-grid",
    "inactive-screensharing-grid"
  );
  videosGrid?.classList.remove("videos-grid-with-screensharing");

  if (screensharingsGrid.children.length > 0) {
    screensharingsGrid.classList.add("active-screensharing-grid");
    videosGrid?.classList.add("videos-grid-with-screensharing");

    resizeVideosGrid("screensharings-grid");
    replaceGridLayoutStyles(videosGrid, videosGrid.children.length > 3 ? 2 : 1);
  } else {
    resizeVideosGrid("videos-grid");
    screensharingsGrid.classList.add("inactive-screensharing-grid");
  }
}

export function addVideoElement(
  peerId: string,
  label: string,
  isLocalVideo: boolean
): void {
  const videoId = elementId(peerId, "video");
  const audioId = elementId(peerId, "audio");

  let video = document.getElementById(videoId) as HTMLVideoElement;
  let audio = document.getElementById(audioId) as HTMLAudioElement;

  if (!video && !audio) {
    const values = setupVideoFeed(peerId, label, isLocalVideo);
    video = values.video;
    audio = values.audio;
  }

  video.id = videoId;
  video.autoplay = true;
  video.playsInline = true;
  video.muted = true;

  audio.id = audioId;
  audio.autoplay = true;
  if (isLocalVideo) {
    audio.muted = true;
  }
}

export function setParticipantsList(participants: Array<string>): void {
  const participantsNamesEl = document.getElementById(
    "participants-list"
  ) as HTMLDivElement;
  participantsNamesEl.innerHTML =
    "<b>Participants</b>: " + participants.join(", ");
}
function resizeVideosGrid(id: string) {
  const grid = document.getElementById(id)!;

  const videos = grid.children.length;

  let videosPerRow;

  // break points for grid layout
  if (videos < 2) {
    videosPerRow = 1;
  } else if (videos < 5) {
    videosPerRow = 2;
  } else if (videos < 7) {
    videosPerRow = 3;
  } else {
    videosPerRow = 4;
  }

  replaceGridLayoutStyles(grid, videosPerRow);
}

function replaceGridLayoutStyles(grid: HTMLElement, videosPerRow: number) {
  let classesToRemove: string[] = [];
  for (const [index, value] of grid.classList.entries()) {
    if (value.includes("grid-cols")) {
      classesToRemove.push(value);
    }
  }

  classesToRemove.forEach((className) => grid.classList.remove(className));

  // add the class to be a default for mobiles
  grid.classList.add("grid-cols-1");
  grid.classList.add(`md:grid-cols-${videosPerRow}`);
}

function setupVideoFeed(peerId: string, label: string, isLocalVideo: boolean) {
  if (isLocalVideo) {
    return setupLocalVideoFeed(peerId, label);
  } else {
    return setupRemoteVideoFeed(peerId, label);
  }
}

function setupLocalVideoFeed(peerId: string, label: string) {
  const copy = (document.querySelector(
    "#local-video-feed-template"
  ) as HTMLTemplateElement).content.cloneNode(true) as Element;
  const feed = copy.querySelector("div[name='video-feed']") as HTMLDivElement;
  const audio = feed.querySelector("audio") as HTMLAudioElement;
  const video = feed.querySelector("video") as HTMLVideoElement;
  const videoLabel = feed.querySelector(
    "div[name='video-label']"
  ) as HTMLDivElement;

  feed.id = elementId(peerId, "feed");
  videoLabel.innerText = label;
  video.classList.add("flip-horizontally");

  const grid = document.querySelector("#videos-grid")!;
  grid.appendChild(feed);
  resizeVideosGrid("videos-grid");

  return { audio, video };
}

function setupRemoteVideoFeed(peerId: string, label: string) {
  const copy = (document.querySelector(
    "#remote-video-feed-template"
  ) as HTMLTemplateElement).content.cloneNode(true) as Element;
  const feed = copy.querySelector("div[name='video-feed']") as HTMLDivElement;
  const audio = feed.querySelector("audio") as HTMLAudioElement;
  const video = feed.querySelector("video") as HTMLVideoElement;
  const videoLabel = feed.querySelector(
    "div[name='video-label']"
  ) as HTMLDivElement;
  feed.id = elementId(peerId, "feed");
  videoLabel.innerText = label;

  const grid = document.querySelector("#videos-grid")!;
  grid.appendChild(feed);
  resizeVideosGrid("videos-grid");
  return { audio, video };
}

function setupScreensharing(peerId: string, label: string) {
  const copy = (document.querySelector(
    "#screensharing-template"
  ) as HTMLTemplateElement).content.cloneNode(true) as Element;
  const feed = copy.querySelector("div[name='video-feed']") as HTMLDivElement;
  const video = feed.querySelector("video") as HTMLVideoElement;
  const videoLabel = feed.querySelector(
    "div[name='video-label']"
  ) as HTMLDivElement;
  const canvas = feed.querySelector("canvas") as HTMLCanvasElement;

  feed.appendChild(canvas);
  feed.id = elementId(peerId, "screensharing");
  videoLabel.innerText = label;

  const grid = document.getElementById("screensharings-grid")!;
  grid.appendChild(feed);
  resizeVideosGrid("screensharings-grid");
  loadCanvas();
  return video;
}

export function removeVideoElement(peerId: string): void {
  document.getElementById(elementId(peerId, "feed"))?.remove();
  resizeVideosGrid("videos-grid");
}

export function setErrorMessage(
  message: string = "Cannot connect to server, refresh the page and try again"
): void {
  const errorContainer = document.getElementById("videochat-error");
  if (errorContainer) {
    errorContainer.innerHTML = message;
    errorContainer.style.display = "flex";
  }
  document.getElementById("videochat")?.remove();
}

export function loadCanvas() {
  var canvas = document.querySelector("#paint");
  var ctx = canvas.getContext("2d");
  var tooltype = "draw";
  var sketch = document.querySelector("#sketch");
  var sketch_style = getComputedStyle(sketch);
  canvas.width = parseInt(sketch_style.getPropertyValue("width"));
  canvas.height = parseInt(sketch_style.getPropertyValue("height"));

  var mouse = { x: 0, y: 0 };
  var last_mouse = { x: 0, y: 0 };

  /* Mouse Capturing Work */
  document.addEventListener(
    "mousemove",
    function (e) {
      last_mouse.x = mouse.x;
      last_mouse.y = mouse.y;
      mouse.x = e.pageX - this.offsetLeft;
      mouse.y = e.pageY - this.offsetTop;
    },
    false
  );

  /* Drawing on Paint App */

  canvas.addEventListener(
    "mousedown",
    function (e) {
      canvas.addEventListener("mousemove", onPaint, false);
    },
    false
  );

  canvas.addEventListener(
    "mouseup",
    function () {
      canvas.removeEventListener("mousemove", onPaint, false);
    },
    false
  );

  var onPaint = function (e) {
    ctx.beginPath();

    if (tooltype != "draw") {
      ctx.globalCompositeOperation = "destination-out";
      ctx.lineWidth = 100;
    } else {
      ctx.globalCompositeOperation = "source-over";
      ctx.strokeStyle = "red";
      ctx.lineWidth = 5;
    }
    mouse.x = e.offsetX;
    mouse.y = e.offsetY;
    ctx.moveTo(last_mouse.x, last_mouse.y);
    ctx.lineTo(mouse.x, mouse.y);
    ctx.lineJoin = "round";
    ctx.lineCap = "round";
    ctx.stroke();
    ctx.closePath();
  };

  var use_tool = function (tool) {
    tooltype = tool;
  };
}
