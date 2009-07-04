class Pixel {
  public int r;
  public int g;
  public int b;
  
  Pixel( int loc_r, int loc_g, int loc_b ) {
    r = loc_r;
    g = loc_g;
    b = loc_b;    
  }

  Pixel() {
    this(0,0,0);
  }    

  Pixel( String loc_r, String loc_g, String loc_b ) {
    this(Integer.parseInt(loc_r), Integer.parseInt(loc_g), Integer.parseInt(loc_b));
  }
  
  public void invert() {
    if( r < 0) {
      if( g < 0 ) {       
        b = ~b;
      }
      g = ~g;
    }  
    r = ~r;          
  }
  
  public boolean equal(Pixel p) {
   if(p == null) return true;
   return this.r == p.r && this.g == p.g && this.b == p.b;
  }
  
  public void copy(Pixel p) {
   if(p == null) return;
   this.r = p.r;
   this.g = p.g;
   this.b = p.b;
  }

  public Pixel clone() {
    return new Pixel(r,g,b); 
  }
}



  /*  public boolean[] get(int x) {
   boolean[] b = { at(r,x), at(g,x), at(b,x) };
   return b;
   }

  
  public boolean get_r(int x) {
    return (r & (1 << x)) > 0;
  }

  public boolean get_g(int x) {
    return (g & (1 << x)) > 0;
  }

  public boolean get_b(int x) {
    return (b & (1 << x)) > 0;
  }
   
   */





