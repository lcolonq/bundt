let initialized = false;
let ctx = null;
let voiceTracks = null;

function initializeCtx() {
  if (!initialized) {
    try {
      initialized = true;
      ctx = new window.AudioContext();
      voiceTracks = [
        document.getElementById("lcolonq-pubnix-index-audio-voice-0"),
        document.getElementById("lcolonq-pubnix-index-audio-voice-1"),
        document.getElementById("lcolonq-pubnix-index-audio-voice-2"),
        document.getElementById("lcolonq-pubnix-index-audio-voice-3"),
        document.getElementById("lcolonq-pubnix-index-audio-voice-4"),
        document.getElementById("lcolonq-pubnix-index-audio-voice-5"),
        document.getElementById("lcolonq-pubnix-index-audio-voice-6"),
      ];
    } catch (e) {
      initialized = false;
    }
  }
}

export const _playVoice = (b) => (i) => () => {
  if (b) initializeCtx();
  try {
    if (initialized) voiceTracks[i].play();
  } catch (e) {}
};
