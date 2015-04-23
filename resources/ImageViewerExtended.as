class ImageViewer extends MovieClip {
  var imageContainer : MovieClip
  var maskClip : MovieClip
  var statusText : TextField

  private var imageLoader : MovieClipLoader

  function ImageViewer() {
    imageContainer = createEmptyMovieClip("imageContainer", 1)

    imageLoader = new MovieClipLoader()
    imageLoader.addListener(this)
  }

  // public

  function loadImage(url : String) {
    imageLoader.loadClip(url, imageContainer)
  }

  // events

  function onLoadProgress(target, bytesLoaded : Number, bytesTotal : Number) {
    statusText.text = "LOADING: "
      + (bytesLoaded / 1024).floor() + "/"
      + (bytesTotal / 1024).floor() + "KB"
  }

  function onLoadInit() {
    imageContainer.setMask(maskClip)
  }

  function onLoadError(target, errorCode : String) {
    if (errorCode == "URLNotFound") {
      statusText.text = "ERROR: File not found."
    } else if (errorCode == "LoadNeverCompleted") {
      statusText.text = "ERROR: Load failed."
    } else {
      statusText.text = "Load error: " + errorCode
    }
  }

  function onUnload() {
    imageLoader.removeListener(this)
  }
}
