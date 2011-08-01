
class Loader extends Thread {
  private PApplet parent;
  public          Loader( PApplet parent ) { this.parent = parent; }
  
  public void run() {
    String[] capture_cameras = null;
    try {
      // Let's get the list of cameras on initialization only. Otherwise we might crash.    
      capture_cameras = Capture.list();
      Thread.sleep(1000);
    } catch( Exception e ) {}
    
    while( true ) {
      try {
        // Then loop through the cameras and see if we should load any of them
        for( String source_name : capture_cameras ) {
          if( source_name.equals( "IIDC FireWire Video" ) ) continue;
          if( source_name.equals( "DV Video" ) ) continue;

          
          // Let's first check if the source already exists
          Camera existing = null;
          for( Camera cam : cameras )
            if( cam.name.equals( source_name ) ) {
              existing = cam;
              break;
            }
          
          // If it does, then check if the source is null and if we should reconnect
          if( existing != null ) {
            if( existing.source == null ) {
              logMessage( "Attempting reconnect... ( " + source_name + " )" );
              existing.reconnect( parent );
            }
          }
          else
          {
            logMessage( "Initializing capture device: " + source_name );
            Camera       cam = new Camera( parent, source_name );
                         cam.register( camera_map );
                         
            cameras.add( cam );
            if( active_cam == null )
                active_cam = cam;
          }
          
          Thread.sleep(1000);
        }
      }
      catch( Exception e ) {}
      
    }
  }
}
