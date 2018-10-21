BFOA bfoa;

PGraphics fuselage;

int repro_steps = 0;

void setup() {
  
  size(640, 480);
  frameRate(30);
  
  noStroke();
  smooth();
  fill(255, 255);
  
  // RANDOM MMOD
  float mmodx = 320 + random(-245, 245);
  float mmody = 240 + random(-195, 195);
  float mmodSize = random(100, 150);

  fuselage = createGraphics(640, 480);
  
  fuselage.beginDraw();
  fuselage.background(9, 24, 51);
  fuselage.noStroke();
  fuselage.fill(113, 28, 145);
  fuselage.ellipse(mmodx, mmody, mmodSize, mmodSize);
  fuselage.endDraw();
  
  background(fuselage);
  
  bfoa = new BFOA(fuselage, 10, 3, 4, 30);

}

void draw() {
 
  repro_steps++;
  
  for (Cell cell : bfoa.cells) {
          
    float x = (cell.vector[0] + 1) * 640 / 2;
    float y = (cell.vector[1] + 1) * 480 / 2;
   
    fill(0,255,159);
    
    rect(x, y, 1, 1);
 
  }
  
  bfoa.reproduce();
  
  if (repro_steps % 20 == 0) {
    bfoa.disperse();
  }
  
}