import ddf.minim.analysis.FFT;
import ddf.minim.*;

FFT fftAnalyzer;
Minim minim;
AudioPlayer song;

// Setup params
static int SCREEN_WIDTH = 800;
static int SCREEN_HEIGHT = 600;
int[][] colors = {{224,46,114},{200,65,161},{152,91,198},{70,112,216},{0,125,215}};
int currentColor = 0;
float brushMax = 3; //Maximum brush size
float brushMin = 2; // Minimum brushSize
float threshold = .56; //Threshold we want to animate
int shapeAmount = 30;
float[] shapes = new float[shapeAmount];
float reductionRate = 0.1;//Make circles move to the center
void setup(){
  frameRate(30);
  noFill();
  //To make circles based of size
  ellipseMode(RADIUS);
  size(800, 600, P3D);
  minim = new Minim(this);
  song = minim.loadFile("./assets/sound.mp3");
  song.play();
  fftAnalyzer = new FFT(song.bufferSize(), song.sampleRate());
  fftAnalyzer.logAverages(22,3);
}

void draw(){
  background(0); //Remove previous painted image
  int[][] coords = {{0,0},{width,0}, {0, height}, {-width, 0}};
  float currentVolume = song.mix.level();
  currentColor = currentVolume >= 0.40 ? (currentColor + 1) % 4 : currentColor;
  //move audio input from both channels
  fftAnalyzer.forward(song.mix); 
  for(int[] coord : coords){     //to place circles in the corners
    translate(coord[0], coord[1]); //to place circles in the corners
    int i = 0;
    while (i < shapeAmount) {
      float amplitude = fftAnalyzer.getAvg(i);
      //When it gets loud we want a cool image
      shapes[i] = amplitude <= threshold ? amplitude * (width/2) : max(0, min(height,shapes[i]-reductionRate));
      //after updating we use the new shape
      float currentShape = shapes[i];
      stroke(amplitude*255,255-(128*amplitude),64,amplitude*255);
      strokeWeight(map(amplitude, 0, 1, brushMax, brushMin));     //We invert it to obtain cool patterns
      ellipse(0, 0, currentShape, currentShape);
      i++;
   }
  }
  translate(0, -height/2); //to move wave to the center
  float bufferSize = song.bufferSize();
  for(int i = 0; i <  bufferSize - 1; i++){
    float x1 = map( i, 0, bufferSize, 0, width );
    float x2 = map( i+1, 0, bufferSize, 0, width );
    stroke(colors[currentColor][0],colors[currentColor][1],colors[currentColor][2],255);
    line( x1, song.mix.get(i)*50, x2,song.mix.get(i+1)*50 );
  }
}
