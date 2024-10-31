class Window{
  float[] coor;
  int show;
  public Window(float[] _coor){
    coor = _coor;
    updateShow();
  }
  void drawWindow(Room room){
    float[] realCoor = room.wallCoor_to_realCoor(coor);
    g.pushMatrix();
    aTranslate(realCoor);
    g.rotateZ(realCoor[3]);
    g.rotateX(-PI/2);
    g.translate(0,0,EPS/2);
    if(show >= WINDOW_COUNT){
      g.rotateY(PI);
    }
    g.image(windowImages[show%WINDOW_COUNT],-WINDOW_W/2,-WINDOW_H/2,WINDOW_W,WINDOW_H);
    g.popMatrix();
  }
  void updateShow(){
    show = (int)random(0,2*WINDOW_COUNT);
  }
}
