class Clickable
{
  
  public String  name          = null;
  public String  disp_name     = null;
  
  public PImage  img           = null;
  public boolean visible       = true;
  public boolean activated     = false;
  public boolean selected      = false;
  public boolean button        = false;
  
  public boolean blink         = true;  // This boolean enables blink on mouse hover
  public int     blink_counter = 0;
  
  
  public float   x             = 0;
  public float   y             = 0;
  public float   w             = 0;
  public float   h             = 0;
  
  int border = 5;
  
  // ---------------------------------------------------------------------------------------- //
  public Clickable( String name, boolean button ) {
    this.name   = name;
    this.button = button;
  }
  
  // ---------------------------------------------------------------------------------------- //
  public void update() {
    textFont ( display_font );
    disp_name = name;
    
    if( img == null ) {
      
      w = 2*border + textWidth( name );
      h = 2*border   + font_size;
      
    } else {
      w = img.width  + 10;
      h = img.height + 10;
      
      float char_length  = name.length();
      float pixel_length = textWidth( name );
      if( pixel_length > img.width ) {
        int chars = (int)(char_length * img.width / pixel_length) - 1;
        disp_name = name.substring( 0, chars );
      }
    }
  }
  
  public boolean every_other( int counter ) { return counter % 2 == 0; }
  
  // ---------------------------------------------------------------------------------------- //
  public void draw() {
    if( !visible ) return;
    
    x = (int)screenX( 0, font_size );
    y = (int)screenY( 0, font_size );

    activated = mouseX >= x && mouseX <= x+w && mouseY >= y-font_size && mouseY  <= y+h-font_size;
    
    if( activated && blink_counter == 0 ) blink_counter = 10;
    
    pushMatrix();
    if( blink_counter > 0 && every_other(blink_counter--) ) {
      translate(random(-1,1),random(-1,1));
    }
    
    
    

    
    int bg = activated ? color(255,255,0) : color(255,255,255);  
    
    if( button ) {
      if( selected ) fill(64,200,32);
      else           fill( activated ? 0 : 32 );
      rect( 0, 0, w, h );
      
      x += border;
      y += border;
    }
    
    if( img != null ) {
      image( img, border, border );
    }
    

    fill(  0 ); text( disp_name, x + 1, y + 1 );
    fill( bg ); text( disp_name, x, y );
    
    popMatrix();
  }
  
  boolean clicked() {
    if( !visible ) return false;
    return activated;
  }
}
