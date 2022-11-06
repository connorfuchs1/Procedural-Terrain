camera myCam = new camera();
float positionX= 0, positionY=0, positionZ=0, Phi, Theta, radius = 100, xPos, yPos;
PVector target = new PVector(0, 0, 0);
float deltaX=0, deltaY=0, GridSize, Rows, Columns;
ArrayList<PVector> points;

color snow = color(255, 255, 255);
color grass = color(143, 170, 64);
color rock = color(135, 135, 135);
color dirt = color(160, 126, 84);
color water = color(0, 75, 200);

import controlP5.*;
ControlP5 cp5;
Textfield load;
Button generate;
Slider heightModifier, snowThreshold;
void setup() {
  size(1200, 800, P3D);
  cp5 = new ControlP5(this);
  perspective(radians(20.0f), (float)width/(float)height, 1, 1000);
  translate(width/2, height/2, 0);
  target.x = 0;
  target.y = 0;
  target.z = 0;

  cp5.addSlider("Rows")
    .setPosition(20, 20)
    .setRange(1, 100)
    ;
  cp5.addSlider("Columns")
    .setPosition(20, 40)
    .setRange(1, 100)
    ;
  heightModifier = cp5.addSlider("Height Modifier")
    .setPosition(210, 80)
    .setRange(-5, 5)
    ;
  snowThreshold = cp5.addSlider("Snow Threshold")
    .setPosition(210, 100)
    .setRange(1, 5)
    ;
  cp5.addSlider("Terrain Size")
    .setPosition(20, 60)
    .setRange(20, 50)
    ;
  generate = cp5.addButton("Generate")
    .setValue(0)
    .setPosition(20, 80)
    .setSize(50, 20)
    ;
  load = cp5.addTextfield("Load from file")
    .setPosition(20, 110)
    .setSize(150, 20)
    .setColor(color(255, 0, 0))
    ;
  cp5.addToggle("Stroke")
    .setPosition(210, 20)
    .setSize(30, 20)
    .setValue(false)
    ;
  cp5.addToggle("Color")
    .setPosition(260, 20)
    .setSize(30, 20)
    ;
  cp5.addToggle("Blend")
    .setPosition(310, 20)
    .setSize(30, 20)
    ;
  background(143, 188, 143);
}

void draw() {
  camera(positionX, positionY, positionZ, // Where is the camera?
    target.x, target.y, target.z, // Where is the camera looking?
    0, 1, 0); // Camera Up vector (0, 1, 0 often, but not always, works)


  if (cp5.isMouseOver()) {
  } else if (mousePressed) {

    deltaX = (mouseX - pmouseX) * .15f;
    deltaY = (mouseY - pmouseY) * .15f;
    myCam.Update();
  }
  //drawing grid
  drawGrid();
  

  camera();
  perspective();
}

boolean bool = false;
void drawGrid() {

  GridSize =  (int) cp5.getController("Terrain Size").getValue();
  Rows = (int)cp5.getController("Rows").getValue();
  Columns = (int)cp5.getController("Columns").getValue();

  ArrayList<PVector> points = new ArrayList<PVector>();

  int y=0;
  for (float x = -(GridSize/2); x<=GridSize/2+.01; x+=(GridSize/Rows)) {
    for (float z = -(GridSize/2); z <= GridSize/2+.01; z+=(GridSize/Columns)) {
      points.add(new PVector(x, y, z));
    }
  }

  //populate triangle indices
  ArrayList<Integer> triangles = new ArrayList<Integer>();

  for (int x = 0; x<Rows; x++) {
    for (int z = 0; z < Columns; z++) {
      int startIndex = x  *  ((int)(Columns+1)) + z;

      triangles.add((int)startIndex);
      triangles.add((int)startIndex+1);
      triangles.add((int)startIndex +(int)(Columns +1));

      triangles.add((int)startIndex+1);
      triangles.add((int)(startIndex+1+ (Columns+1)));
      triangles.add((int)startIndex + ((int)Columns +1));
    }
  }
  
  if(generate.isPressed()){
    bool = true;
  }
  if(bool == true){
  //loading files
  String fileName;
  fileName = load.getText() +".png";

  PImage image = loadImage(fileName);
  if (image == null) {
    
  } else {
    int xIndex= 0, yIndex =0;
    for (int i =0; i <= Rows; i++) {
      for (int j =0; j<= Columns; j++) {
        xIndex = (int) map(Columns-j, 0, Columns+1, 0, image.width);
        yIndex = (int) map(i, 0, Rows+1, 0, image.height);
        color imageColor = image.get(xIndex, yIndex);
        float heightFromColor = map(red(imageColor), 0, 255, 0, 1.0f);
        int vertexIndex = (int)(i * (Columns+1) + j);
        points.get(vertexIndex).y = heightFromColor * -heightModifier.getValue();
      }
    }
  }
  
  
  
  background(143, 188, 143);
  beginShape(TRIANGLES);
  
  if (cp5.getController("Stroke").getValue() == 1) {
    stroke(1);
    strokeWeight(1);
  } else {
    noStroke();
  }


  for (int p = 0; p < triangles.size(); p++) {
    int vertIndex = triangles.get(p);
    PVector vert = points.get(vertIndex);

    //coloring
    if (cp5.getController("Color").getValue() == 1) {
      float relativeHeight = (abs(vert.y * -heightModifier.getValue() / -(snowThreshold.getValue()*4.5)));
     
      if (relativeHeight >= .8) {

        if (cp5.getController("Blend").getValue() == 1) {
          float ratio = (relativeHeight - .8) / .2f;
          color blend = lerpColor(rock, snow, ratio);
          fill(blend);
        } else {
          fill(snow);
        }
      } else if (relativeHeight >= .4 && relativeHeight < .8) {

        if (cp5.getController("Blend").getValue() == 1) {
          float ratio = (relativeHeight - .4) / .4f;
          color blend = lerpColor(grass, rock, ratio);
          fill(blend);
        } else {
          fill(rock);
        }
      } else if (relativeHeight >= .2 && relativeHeight < .4) {

        if (cp5.getController("Blend").getValue() == 1) {
          float ratio = (relativeHeight - .2) / .2f;
          color blend = lerpColor(dirt, grass, ratio);
          fill(blend);
        } else {
          fill(grass);
        }
      } else {
        if (cp5.getController("Blend").getValue() == 1) {
          float ratio = (relativeHeight) / .2f;
          color blend = lerpColor(water, dirt, ratio);
          fill(blend);
        } else {
          fill(water);
        }
      }
    }
    else{
      fill(255,255,255);
      
    }
    vertex(vert.x, vert.y, vert.z);
  }

endShape();
  }
  
}

public class camera {
  void Update() {

    Phi += deltaX;
    if (Theta + deltaY < 179 && Theta + deltaY > 0) {
      Theta += deltaY;
    }

    positionX = target.x + radius * cos(radians(Phi)) * sin(radians(Theta));
    positionY = target.y + radius * cos(radians(Theta));
    positionZ = target.z + radius * sin(radians(Theta)) * sin(radians(Phi));
  }
}
