import SimpleOpenNI.*;
import gab.opencv.*;
import java.awt.Rectangle;

public class DetectState  {

  public boolean takingPhoto = false;
  public int detectRotate = 0;
  public int detectDelay = 0;
  public int moveOffset = 0;

  public DetectState () {
    
  }
}

SimpleOpenNI  context;
OpenCV opencv;
DetectState detectState;
Rectangle[] faces;

int max_len = 0;

void setup()
{

  context = new SimpleOpenNI(this);
  detectState = new DetectState();

  context.enableDepth();
  context.enableRGB();
  context.setMirror(true);
  context.enableHand();
  context.startGesture(SimpleOpenNI.GESTURE_HAND_RAISE);

  background(200,0,0);

  max_len= (int)dist(context.rgbWidth() 
    , context.rgbHeight(),0,0);
  size(max_len,max_len); 

}

void draw()
{
  // clear background
  background(255);

  //get new frame
  context.update();

  // move and show the new frame image
  pushMatrix();

    translate(max_len/2-context.rgbWidth() /2
      , max_len/2-context.rgbHeight()/2);

    image(context.rgbImage(), 0, 0);
  popMatrix();

  if(detectState.detectDelay<100 
    && detectState.takingPhoto){

    translate(max_len/2,max_len/2);
    translate(0, detectState.moveOffset);

    if(detectState.detectDelay > 20 
      && detectState.detectDelay < 100){

      rotate(detectState.detectRotate*TWO_PI/360);
      if(detectState.detectDelay < 40)
        detectState.detectRotate+=2.8f;
    }

    if(detectState.detectDelay>= 60){

      detectState.moveOffset-=max_len/40;
    }

    translate(-opencv.getInput().width/2
      , -opencv.getInput().height/2);

    image(opencv.getInput(), 0 , 0);

    noFill();
    stroke(0, 255, 0);
    strokeWeight(3);
    for (Rectangle face: faces) {

        rect(face.x, face.y, face.width, face.height);
    }
    
    detectState.detectDelay++;

  }
  else {
    detectState = new DetectState();
  }

}


void onCompletedGesture(SimpleOpenNI curContext
  , int gestureType
  , PVector pos)
{
  if(detectState.takingPhoto==false 
    && detectState.detectDelay==0){

    opencv= new OpenCV(this,context.rgbImage());
    opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  
    faces = opencv.detect();
    detectState.takingPhoto=true;
  }
}
