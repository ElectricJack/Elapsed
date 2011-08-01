
//class CameraHistory {
//}

class Camera {
  // cam.format() : Capture.NTSC, Capture.PAL, or Capture.SECAM
  // cam.source() : Capture.TUNER, Capture.COMPOSITE, Capture.SVIDEO, or Capture.COMPONENT
  
  String     name             = "";
  Capture    source           = null;  // The capture source being read from
  Clickable  ui               = null;
  int        next_image_index = 0;     // The index of the next image filename
  
  PImage[]   history          = null;  // A history of thumbnail images of the capture
  int        history_count    = 0;
  int        history_index    = 0;  
  boolean    history_enabled  = true;
  
  int        resolution       = 1;
  int        frame_time       = 0;
  int        last_time        = 0;
  
  // ---------------------------------------------------------------------------------------- //
  public Camera( PApplet parent, String name ) {
    init( parent, name, 640, 480, 30 );
    this.name = name;
    this.ui   = new Clickable( name, true );
    
    enableHistory(32);
    
  }
  
  public String  getName () { return name; }
  public int     getFrameTime( ) { return frame_times_milis[ frame_time ]; }
  
  // ---------------------------------------------------------------------------------------- //
  public float   getWidth       ( )                 { if( source != null ) return source.width;  return 0; }
  public float   getHeight      ( )                 { if( source != null ) return source.height; return 0; }
  public void    disableHistory ( )                 { history_enabled = false; history = null; }
  public void    enableHistory  ( int frame_count ) {
    history_enabled = true;
    history         = new PImage[ frame_count ];    
  }
  
  
  // ---------------------------------------------------------------------------------------- //
  public void draw( )                                            { draw( 0, 0, source.width, source.height ); }
  public void draw( float x, float y, float width, float height) {
    if( source != null ) { 
      
      PImage img = source;
      if( img != null) {
        //println( name + " - draw " + width + ", " + height );
        image(img, x, y, width, height );
        
        if( history_count > 0 ) { 
          float s = 0.125;
          history_index++;
          history_index %= history_count;
          PImage hist_img = history[history_index];

          if( hist_img != null )
            image( hist_img, x+width-width*s-2, y+2, width*s, height*s );
        }
      }
    }
  }

  // ---------------------------------------------------------------------------------------- //
  public void register( HashMap<Capture, Camera> which ) {
    which.put( this.source, this );
  }
  
  // ---------------------------------------------------------------------------------------- //
  public void capture() {
    if( source == null      ) { return; }
    if( !source.available() ) { return; }
    
                        source.read();
    PImage        img = source.get();
                  img.resize( 80,  60 );
    this.ui.img = img;
  }
  
  // ---------------------------------------------------------------------------------------- //
  public void saveImage() {
    if( source == null )  return;
    
    PImage frame    = source.get();
           frame.save( getImagePath( name, next_image_index++ ) );
    
    if( history_enabled ) {
      frame.resize ( 160, 120  );
      this.add_history( frame );
    }
  }
  
  // ---------------------------------------------------------------------------------------- //
  public void add_history( PImage frame ) {
      PImage f = frame.get();
      if( f == null ) return;
      if( history_count < history.length ) {
        history[ history_count++ ] = f;
      }
  }
  
  // ---------------------------------------------------------------------------------------- //
  public void reconnect( PApplet parent ) {
    int w = res_widths[resolution];
    int h = res_heights[resolution];
    init( parent, name, w, h, 30 );
    camera_map.put( this.source, this );
  }
  
  // ---------------------------------------------------------------------------------------- //
  public void init( PApplet parent, String name, int w, int h, int fps ) {
    
    try { source = new Capture( parent, w, h, name, fps ); }
    catch( Exception e ) { println( "err" ); }
    catch( Throwable e ) { }
    
    this.name = name;
  }
}
