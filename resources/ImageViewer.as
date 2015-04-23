class ImageViewer {
  // The movie clip that will contain the all ImageViewer assets.
  private var container_mc:MovieClip;
  // The movie clip to which the container_mc will be attached.
  private var target_mc:MovieClip;

  // Depths for visual assets.
  private var containerDepth:Number;
  private static var imageDepth:Number = 0;
  private static var maskDepth:Number = 1;
  private static var borderDepth:Number = 2;
  private static var statusDepth:Number = 3;

  // The thickness of the border around the image.
  private var borderThickness:Number;
  // The color of the border around the image.
  private var borderColor:Number;

  // The MovieClipLoader instance used to load the image.
  private var imageLoader:MovieClipLoader;

  public function ImageViewer (target:MovieClip,
                               depth:Number,
                               x:Number,
                               y:Number,
                               w:Number,
                               h:Number,
                               borderThickness:Number,
                               borderColor:Number) {
    // Assign property values.
    target_mc = target;
    containerDepth = depth;
    this.borderThickness = borderThickness;
    this.borderColor = borderColor;
    imageLoader = new MovieClipLoader();

    // Register this instance to receive  events
    // from the imageLoader instance.
    imageLoader.addListener(this);

    // Set up the visual assets for this ImageViewer.
    buildViewer(x, y, w, h);
  }

  private function buildViewer (x:Number,
                                y:Number,
                                w:Number,
                                h:Number):Void {
      // Create the clips to hold the image, mask, and border.
      createMainContainer(x, y);
      createImageClip();
      createImageClipMask(w, h);
      createBorder(w, h);
  }

  private function createMainContainer (x:Number, y:Number):Void {
    container_mc = target_mc.createEmptyMovieClip("container_mc" + containerDepth, containerDepth);
    container_mc._x = x;
    container_mc._y = y;
  }

  private function createImageClip ():Void {
    container_mc.createEmptyMovieClip("image_mc", imageDepth);
  }

  private function createImageClipMask (w:Number,
                                        h:Number):Void {
    // Only create the mask if a valid width and height are specified.
    if (!(w > 0 && h > 0)) {
      return;
    }

    // In the container, create a clip to act as the mask over the image.
    container_mc.createEmptyMovieClip("mask_mc", maskDepth);

    // Draw a rectangle in the mask.
    container_mc.mask_mc.moveTo(0, 0);
    container_mc.mask_mc.beginFill(0x0000FF);  // Use blue for debugging.
    container_mc.mask_mc.lineTo(w, 0);
    container_mc.mask_mc.lineTo(w, h);
    container_mc.mask_mc.lineTo(0, h);
    container_mc.mask_mc.lineTo(0, 0);
    container_mc.mask_mc.endFill();

    // Hide the mask (it will still function as a mask when invisible).
    container_mc.mask_mc._visible = false;
  }

  private function createBorder (w:Number,
                                 h:Number):Void {
    // Only create the border if a valid width and height are specified.
    if (!(w > 0 && h > 0)) {
      return;
    }

    // In the container, create a clip to hold the border around the image.
    container_mc.createEmptyMovieClip("border_mc", borderDepth);

    // Draw a rectangular outline in the border clip, with the
    // specified dimensions and color.
    container_mc.border_mc.lineStyle(borderThickness, borderColor);
    container_mc.border_mc.moveTo(0, 0);
    container_mc.border_mc.lineTo(w, 0);
    container_mc.border_mc.lineTo(w, h);
    container_mc.border_mc.lineTo(0, h);
    container_mc.border_mc.lineTo(0, 0);
  }

  public function loadImage (URL:String):Void {
    imageLoader.loadClip(URL, container_mc.image_mc);

    // Create a load-status text field to show the user load progress.
    container_mc.createTextField("loadStatus_txt", statusDepth, 0, 0, 0, 0);
    container_mc.loadStatus_txt.background = true;
    container_mc.loadStatus_txt.border = true;
    container_mc.loadStatus_txt.setNewTextFormat(new TextFormat(
                                                 "Arial, Helvetica, _sans",
                                                 10, borderColor, false,
                                                 false, false, null, null,
                                                 "right"));
    container_mc.loadStatus_txt.autoSize = "left";

    // Position the load-status text field
    container_mc.loadStatus_txt._y = 3;
    container_mc.loadStatus_txt._x = 3;

    // Indicate that the image is loading.
    container_mc.loadStatus_txt.text = "LOADING";
  }

  public function onLoadProgress (target:MovieClip,
                                  bytesLoaded:Number,
                                  bytesTotal:Number):Void {
    container_mc.loadStatus_txt.text = "LOADING: "
        + Math.floor(bytesLoaded / 1024)
        + "/" + Math.floor(bytesTotal / 1024) + " KB";
  }

  public function onLoadInit (target:MovieClip):Void {
    // Remove the loading message.
    container_mc.loadStatus_txt.removeTextField();

    // Apply the mask to the loaded image.
    container_mc.image_mc.setMask(container_mc.mask_mc);
  }

  public function onLoadError (target:MovieClip, errorCode:String):Void {
    if (errorCode == "URLNotFound") {
      container_mc.loadStatus_txt.text = "ERROR: File not found.";
    } else if (errorCode == "LoadNeverCompleted") {
      container_mc.loadStatus_txt.text = "ERROR: Load failed.";
    } else {
      // Catch-all to handle possible future errorCodes.
      container_mc.loadStatus_txt.text = "Load error: " + errorCode;
    }
  }

  public function destroy ():Void {
    // Cancel load event notifications.
    imageLoader.removeListener(this);
    // Remove movie clips from Stage.
    container_mc.removeMovieClip();
  }
}
