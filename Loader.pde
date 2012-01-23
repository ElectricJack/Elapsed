
class Loader extends Thread {
  private PApplet parent;
  public          Loader( PApplet parent ) { this.parent = parent; }
  
  public void run() {
    List<String> capture_cameras = new ArrayList<String>();
    for( Camera cam : settings.getCameras() ) {
      if( cam == null || cam.name == null || cam.name.isEmpty() ) continue;
      try {
        cam.reconnect( parent );
        capture_cameras.add( cam.name );
      } catch( Exception e ) {
        println( "Error connecting to previously used camera..." );
      }
    }
    
    try {
      println("Getting list of cameras...");
      // Let's get the list of cameras on initialization only. Otherwise we might crash.    
      String[] capture_cams = Capture.list();
      for( String cam : capture_cams )
        capture_cameras.add( cam );
      Thread.sleep(100);
      println("Done!");
    } catch( Exception e ) {
      //e.printStackTrace();
    }
    
    while( true ) {
      try {

        // Then loop through the cameras and see if we should load any of them
        for( String source_name : capture_cameras ) {
          
          //source_name = sanitizeCameraName( source_name );
          if( source_name.equals( "IIDC FireWire Video" ) ) continue;
          if( source_name.equals( "DV Video" ) ) continue;
          if( source_name.contains( "Google Camera Adapter" ) ) continue;

          
          // Let's first check if the source already exists
          Camera existing = null;
          for( Camera cam : settings.getCameras() ) {
            if( cam == null || cam.name == null || cam.name.isEmpty() ) continue;
            if( cam.name.equals( source_name ) ) {
              existing = cam;
              break;
            }
          }
          
          // If it does, then check if the source is null and if we should reconnect
          if( existing != null ) {
            if( existing.source == null ) {
              logMessage( "Attempting reconnect... ( " + source_name + " )" );
              existing.reconnect( parent );
              logMessage( "Loading complete!" );
            }
          }
          else
          {
            logMessage( "Initializing capture device: " + source_name );
            Camera       cam = new Camera();
                         cam.init( parent, source_name );
                         cam.register( camera_map );
                         
            settings.addCamera( cam );
          }
          Thread.sleep(100);
        }
        
      }
      catch( Exception e ) {}
      
    }
  }
}
