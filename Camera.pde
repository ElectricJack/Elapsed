
class Camera implements Serializable {
  // cam.format() : Capture.NTSC, Capture.PAL, or Capture.SECAM
  // cam.source() : Capture.TUNER, Capture.COMPOSITE, Capture.SVIDEO, or Capture.COMPONENT
  
  private String     name             = "";
  private String     realname         = "";
  private boolean    active           = true;
  private int        next_image_index = 0;     // The index of the next image filename
  

  private boolean    history_enabled  = true;

  
  private int        update_rate      = 30;
  private int        resolution       = 1;
  private int        width            = 640;
  private int        height           = 480;
  private int        frame_time       = 0;

  
  public String       getType   ( ) { return "Camera";      }
  public Serializable clone     ( ) { return new Camera(); }
  public void         serialize ( Serializer s ) {
    name             = s.serialize( "name",             name );
    active           = s.serialize( "active",           active );
    next_image_index = s.serialize( "next_image_index", next_image_index );
    history_enabled  = s.serialize( "history_enabled",  history_enabled );
    resolution       = s.serialize( "resolution",       resolution );   
    update_rate      = s.serialize( "update_rate",      update_rate );
    frame_time       = s.serialize( "frame_time",       frame_time );
    
    width  = res_widths[resolution];
    height = res_heights[resolution];
  }
  
  private int        history_count    = 0;
  private int        history_index    = 0;  
  private int        last_time        = 0;
  private PImage[]   history          = null;  // A history of thumbnail images of the capture
  private Capture    source           = null;  // The capture source being read from
  private Clickable  ui               = null;


  
  // ---------------------------------------------------------------------------------------- //
  public Camera() {}
  
  // ---------------------------------------------------------------------------------------- //
  public void reconnect( PApplet parent ) {
    width  = res_widths[resolution];
    height = res_heights[resolution];
    unregister( camera_map );
    history_count = 0;
    history_index = 0;
    init( parent, name, width, height, update_rate );
    register( camera_map );
  }
  // ---------------------------------------------------------------------------------------- //
  public void unregister( HashMap<Capture, Camera> which ) {
    if( this != null && this.source != null && which != null ) {
      synchronized( this.source ) {
        this.source.dispose();
        synchronized( which ) {
          which.remove( this.source );
        }
        this.source = null;
      }
    }
  }
  // ---------------------------------------------------------------------------------------- //
  public void register( HashMap<Capture, Camera> which ) {
    
    if( this != null && this.source != null && which != null ) {
      synchronized( this.source ) {
        synchronized( which ) {
          which.put( this.source, this );
        }
      }
    }
  }
  // ---------------------------------------------------------------------------------------- //
  public void init( PApplet parent ) {
    init( parent, this.name );
  }
  // ---------------------------------------------------------------------------------------- //
  public void init( PApplet parent, String name ) {
    init( parent, name, res_widths[resolution], res_heights[resolution], update_rate );
  }
  // ---------------------------------------------------------------------------------------- //
  public void init( PApplet parent, String name, int w, int h, int fps ) {
    
    this.name = name;
    this.ui   = new Clickable( name, true );
    
    if( history_enabled )
      enableHistory(32);
    
    try { source = new Capture( parent, w, h, name, fps ); }
    catch( Exception e ) { println( "Error initializing camera: " + name ); e.printStackTrace(); }
    catch( Throwable e ) { println( "Error initializing camera: " + name ); e.printStackTrace(); }
  }
  
  public String  getName () { return name; }
  public int     getFrameTime( ) { return frame_times_milis[ frame_time ]; }
  
  // ---------------------------------------------------------------------------------------- //
  public float   getWidth       ( )                 { return width; }
  public float   getHeight      ( )                 { return height; }
  public void    disableHistory ( )                 { history_enabled = false; history = null; }
  public void    enableHistory  ( int frame_count ) {
    history_enabled = true;
    history         = new PImage[ frame_count ];    
  }
  
  
  // ---------------------------------------------------------------------------------------- //
  public void draw( )                                            { draw( 0, 0, getWidth(), getHeight() ); }
  public void draw( float x, float y, float width, float height) {
    if( source != null ) { 
      PImage img = source;
      if( img != null && img.width > 0 && img.height > 0 ) {
        
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
  public void capture() {
    if( source == null      ) { return; }
    
                        //source.read();
    PImage        img = source.get();
                  img.resize( 80,  60 );
    this.ui.img = img;
  }
  
  // ---------------------------------------------------------------------------------------- //
  public void saveImage() {
    if( source == null )  return;
    
    PImage frame = source.get();
    if( frame != null ) {
      frame.save( getImagePath( name, next_image_index++ ) );
    }
           
    
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
  

  

}
