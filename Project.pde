class Project {
  private String     name;
  private String     folder;
  public  Clickable  ui;
  
  public String getName()   { return name; }
  public String getFolder() { return folder; }
  
  public Project( File project_folder ) {
    this.name   = project_folder.getName();
    this.folder = project_folder.getAbsolutePath();
    this.ui     = new Clickable( this.name, true );
    
    // Get an array of all of the jpg's in the project folder and subfolders
    ArrayList<File> project_images = new ArrayList<File>();
    selectFiles( project_images, new File( folder ), "[\\w]+\\.jpg", true );
    
    if( project_images != null && project_images.size() > 0 ) {
      
      /*if( active_cam != null ) {
       for( File img : project_images ) {
         String path   = img.getAbsolutePath();
         PImage loaded = loadImage( path );
         active_cam.add_history( loaded );
       }
      }*/
      // Pick an image from the list that's close to the end
      File image_file = project_images.get( (int)(project_images.size() * 0.75) );
      // Load the image
      ui.img = loadImage( image_file.getAbsolutePath() );
      ui.img.resize(160,120);
    }
  }
}

// ---------------------------------------------------------------------------------------- //
void deleteProject( Project prj ) {
  
  if( active_project == prj )
      active_project = null;
      
  // Get an array of all of the jpg's in the project folder and subfolders
  ArrayList<File> project_images = new ArrayList<File>();
  File            project_folder = new File( prj.getFolder() );
  selectFiles( project_images, project_folder, "[\\w]+\\.jpg", true );
  
  // If there are any images, prompt asking if the user really wants to delete the project
  boolean delete = true;
  if( project_images != null ) {
    
    int project_imgs = project_images.size();
    if( project_imgs > 0 ) {
      String message = "Are you sure you want to delete project '" + prj.getName() + "' with " + project_imgs + " image(s) in it?";
      delete = ( JOptionPane.showConfirmDialog( frame
                                              , message
                                              , "Delete Project?"
                                              , JOptionPane.YES_NO_OPTION
                                              , JOptionPane.QUESTION_MESSAGE ) == JOptionPane.YES_OPTION );
    }
    else delete = true;
  }
  
  // Follow orders!
  if( delete ) {
    if( project_images != null ) 
      for( File img : project_images )
        img.delete();

    ArrayList<File> camera_folders = new ArrayList<File>();
    selectFiles( camera_folders, project_folder, null, false );
    for( File camera_folder : camera_folders )
      camera_folder.delete();

    project_folder.delete();
    
    projects.remove( prj );
  }
}

// ---------------------------------------------------------------------------------------- //
void newProject() {
  
  ArrayList<File> project_folders = new ArrayList<File>();
  selectFiles( project_folders, new File( root_folder ), null, false );
  
  int max_index = 0;
  for( File folder : project_folders ) {
    String[] name_index = folder.getName().split("_");
    if( name_index != null && name_index.length > 1 ) {
      int index = Integer.parseInt( name_index[1] );
      max_index = max_index < index ? index : max_index;
    }
  }
  
  String new_project_name = "Project_" + withLeadingZeros( max_index + 1, 3 );
  
  File project_folder = new File( root_folder + slash + new_project_name );
       project_folder.mkdir();
  
  active_project = new Project( project_folder );
  projects.add( active_project );
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

  File project_folder_file = new File( root_folder + slash + active_project.getName() );
  File camera_folder_file  = new File( root_folder + slash + active_project.getName() + slash + camera_name );
  
  if( !project_folder_file.exists() ) project_folder_file.mkdir();
  if( !camera_folder_file.exists()  ) camera_folder_file.mkdir();
  
  return camera_folder_file.getAbsolutePath() + slash + "frame" + index_string + ".jpg";
}

// ---------------------------------------------------------------------------------------- //
void initAppSettings() {
  
  // Set our default application settings
         project_name   = "Project";
         root_folder    = sketchPath("projects");
  String active_project = null;
  
  // Parse the settings file if it exists
  String[] settings = loadStrings("settings.ini"); 
  if( settings == null ) logMessage( "No settings file found!" );  
  else {
    
    for( String setting : settings ) {
      if( setting.length() == 0 ) continue;
      
      String[] keyval = setting.toLowerCase().split(":");
      String   key    = keyval[0].trim();
      String   val    = keyval[1].trim();
      
      if      ( key.equals( "projects folder" ) ) root_folder    = val;
      else if ( key.equals( "active project"  ) ) active_project = val;
    }
  }
    
  // Check if the projects folder exists, and create it if it does not
  File root_folder_test = new File(root_folder);
  if( !root_folder_test.exists() ) {
    logMessage( "No project folder found, creating it!" );  
    root_folder_test.mkdir();
  }
  
  // Load all the available projects
  ArrayList<File> project_folders = new ArrayList<File>();
  selectFiles( project_folders, new File( root_folder ), null, false );
  for( File project_folder : project_folders ) {
    projects.add( new Project( project_folder ) );
  }
  
}

// ---------------------------------------------------------------------------------------- //
void selectFiles( ArrayList<File> out, File folder, String types, boolean recurse )
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

// ---------------------------------------------------------------------------------------- //
void saveAppSettings() {
  //File 
}

