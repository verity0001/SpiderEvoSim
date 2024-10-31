class Swatter{
  int index = 0;
  int visIndex = 0;
  float[] coor;
  float percentage = 0;
  float BAR_THICKNESS = 10;
  float SWATTER_THICKNESS = 6;
  int killCount = 0;
  public Swatter(int i, float p, Room room, ArrayList<Swatter> swatters){
    index = i;
    refresh(room, false, swatters);
    percentage = p;
  }
  void refresh(Room room, boolean newP, ArrayList<Swatter> swatters){
    coor = new float[2];
    boolean freeToPlace = false;
    int attempts = 0;
    while(!freeToPlace){
      for(int d = 0; d < 2; d++){
        float max_ = room.getMaxDim(d);
        coor[d] = random(0,max_);
        coor[d] = min(max(coor[d],0+R),max_-R);
      }
      freeToPlace = true;
      attempts++;
      if(attempts < 40){
        for(int i = 0; i < swatters.size(); i++){
          if(i != index){
            if(abs(swatters.get(i).coor[0] - coor[0]) < 280 && abs(swatters.get(i).coor[1] - coor[1]) < 280){
              freeToPlace = false; // This would overlap with another swatter, so try to place it somewhere else.
            }
          }
        }
      }
    }
    visIndex = totalSwatterIndex;
    totalSwatterIndex++;
    killCount = 0;
    if(newP){
      percentage = 1.0;
    }
  }
  void drawSwatter(Room room){
    float[] swatterCoor = room.swatterHelper(coor, R);
    for(int s = 0; s < swatterCoor.length-1; s++){
      float W = swatterCoor[s+1]-swatterCoor[s];
      float[] this_coor = {swatterCoor[s],coor[1]};
      float[] realCoor = room.wallCoor_to_realCoor(this_coor);
      
      g.pushMatrix();
      aTranslate(realCoor);
      //g.fill(darken(WALL_COLOR, sqrt(percentage)));
      g.fill(darken(WALL_COLOR, pow(percentage,0.25)));
      g.rotateZ(realCoor[3]);
      g.rotateX(PI/2);
      g.translate(0,0,-EPS);
      if(percentage >= 0){
        g.rect(0,-R,W,R*2);
      }
      
      float p = max(0,percentage);
      g.translate(W/2,0,-SWATTER_THICKNESS*0.5);
      g.translate(0,R*2,0);
      float tiltDown = sqrt(min(p,0.5)/0.5);
      g.rotateX(PI/2*tiltDown);
      float scale_ = min(min(1.0,(1-p)/0.5), cosInter((percentage+0.4)/0.4));
      g.scale(scale_);
      g.fill(60);
      g.translate(0,-R,0);
      g.box(BAR_THICKNESS,R*2,SWATTER_THICKNESS-EPS);
      g.translate(0,-R,0);
      g.fill(150);
      g.box(W+EPS,R*2,SWATTER_THICKNESS);
      if(W >= min(60,R) && killCount >= 1){
        g.pushMatrix();
        g.translate(0,0,-SWATTER_THICKNESS*0.5-EPS);
        g.rotateX(PI);
        g.scale(min(1.0,R/60.0));
        g.fill(0);
        g.textAlign(CENTER);
        g.textSize(65);
        g.text(killCount,0,0);
        g.textSize(40);
        String killText = (killCount >= 2) ? "kills" : "kill";
        g.text(killText,0,40);
        g.popMatrix();
      }
      g.popMatrix();
    }
  }
  float cosInter(float x){
    float x2 = min(max(x,0),1);
    return 0.5-0.5*cos(x2*PI);
  }
  void iterate(Room room, ArrayList<Spider> spiders, ArrayList<Swatter> swatters){
    percentage -= SWAT_SPEED;
    if(percentage < 0 && percentage+SWAT_SPEED >= 0){ // smash! Let's see if we killed any spiders.
      swat(spiders);
    }
    if(percentage < -0.4){
      refresh(room, true, swatters);
    }
  }
  void swat(ArrayList<Spider> spiders){
    boolean killed = false;
    for(int s = 0; s < spiders.size(); s++){
      Spider sp = spiders.get(s);
      if(abs(sp.coor[0]-coor[0]) < R && abs(sp.coor[1]-coor[1]) < R){ // This spider was in our range! We killed it!
        sp.reincarnate(spiders);
        killCount++;
        totalIndex++;
        killed = true;
      }
    }
    
    float[] realWorldCoor = room.wallCoor_to_realCoor(coor);
    float dist_ = dist(player.coor[0],player.coor[1],player.coor[2],realWorldCoor[0],realWorldCoor[1],realWorldCoor[2]);
    int choice = (int)random(0,3);
    if(killed){
      choice += 3;
    }
    if(playback_speed <= 2){
      sfx[choice].play();
      sfx[choice].amp(5/(1+dist_/33));
      sfx[choice].rate(random(0.8,1.2));
    }
  }
}
