
class Project implements Serializable {
  private String                    name          = "";
  private String                    folder        = "";
  private int                       active_camera = -1;
  
  public  Clickable                 ui;
  
  public String       getType   ( ) { return "Project";     }
  // ---------------------------------------------------------------------------------------- //
  public Serializable clone     ( ) { return new Project(); }
  // ---------------------------------------------------------------------------------------- //
  public void         serialize ( Serializer s ) {
    name           = s.serialize( "name",    name );
    folder         = s.serialize( "folder",  folder );
    active_camera  = s.serialize( "active_camera",  active_camera );      
  }

  // ---------------------------------------------------------------------------------------- //
  public void setActiveCamera( ProjectSettings parent,  int index ) {
    if( index >= 0 && index < parent.getCameras().size() )
      active_camera = index;
  }
  // ---------------------------------------------------------------------------------------- //
  public Camera getActiveCamera( ProjectSettings parent ) {
    if( active_camera == -1 && parent.getCameras().size() > 0 )
      active_camera = 0;
    
    if( active_camera >= 0 && active_camera < parent.getCameras().size() ) {
      return parent.getCameras().get( active_camera );
    }
    return null;
  }
  // ---------------------------------------------------------------------------------------- //
  public boolean hasActiveCamera() { return active_camera > -1; }
  // ---------------------------------------------------------------------------------------- //
  public String getName()   { return name; }
  // ---------------------------------------------------------------------------------------- //
  public String getFolder() { return folder; }

  
  // ---------------------------------------------------------------------------------------- //
  public void init() {
    init( new File( folder ) );
  }
  // ---------------------------------------------------------------------------------------- //
  public void init( File project_folder ) {
    this.name   = project_folder.getName();
    this.folder = project_folder.getAbsolutePath();
    this.ui     = new Clickable( this.name, true );
    
    // Get an array of all of the jpg's in the project folder and subfolders
    ArrayList<File> project_images = new ArrayList<File>();
    selectFiles( project_images, new File( folder ), "[\\w]+\\.jpg", true );
    
    if( project_images != null && project_images.size() > 0 ) {
      // Pick an image from the list that's close to the end
      File image_file = project_images.get( (int)(project_images.size() * 0.75) );
      // Load the image
      ui.img = loadImage( image_file.getAbsolutePath() );
      ui.img.resize(160,120);
    }
  }
}






// ---------------------------------------------------------------------------------------- //
String withLeadingZeros( int index, int digits ) {
  String index_string = Integer.toString( index );
  for( int zeros_to_add = digits - index_string.length(); zeros_to_add > 0; --zeros_to_add )
    index_string = "0" + index_string;
  return index_string;
}

// ---------------------------------------------------------------------------------------- //
// @TODO: This should probably be moved into the Project class
String getImagePath( String camera_name, int image_index ) {

  // Add leading zeros  
  String index_string = withLeadingZeros( image_index, 6 );

  Project active_project = settings.getActiveProject();
  if( active_project != null ) {
    File project_folder_file = new File( settings.root_folder + slash + active_project.getName() );
    File camera_folder_file  = new File( settings.root_folder + slash + active_project.getName() + slash + camera_name );
    
    if( !project_folder_file.exists() ) project_folder_file.mkdir();
    if( !camera_folder_file.exists()  ) camera_folder_file.mkdir();
    
    return camera_folder_file.getAbsolutePath() + slash + "frame" + index_string + ".jpg";
  }
  return null;
}

// ---------------------------------------------------------------------------------------- //
void selectFiles( List<File> out, File folder, String types, boolean recurse )
{
  if( !folder.isDirectory() ) return;
    
  for( File file : folder.listFiles() ) {
    if( recurse ) selectFiles( out, file, types, true );
    
    if( types != null && !file.getName().matches( types ) )
      continue;
      
    if( types == null ) {
      if( file.isDirectory() )
        out.add( file );
    }
    else out.add( file );
  }
}


