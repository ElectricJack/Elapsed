public class ProjectSettings implements Serializable {
  
  public  String           root_folder;
  private int              active_project   = -1;
  private List<Project>    projects         = new ArrayList<Project>();
  private Vector<Camera>   cameras          = new Vector<Camera>();
  
  public ProjectSettings() {
    root_folder = sketchPath("projects");
  }
  
  public String       getType   ( ) { return "ProjectSettings";     }
  public Serializable clone     ( ) { return new ProjectSettings(); }
  public void         serialize ( Serializer s ) {
    root_folder       = s.serialize( "root_folder",      root_folder );
    active_project    = s.serialize( "active_project",   active_project );
                        s.serialize( "projects",         projects );
                        s.serialize( "cameras",          cameras );
  }
  
  // ---------------------------------------------------------------------------------------- //
  public void init( PApplet parent ) {
    for( Project project : projects )
      project.init();
    initCameras( parent );
  }
  
  // ---------------------------------------------------------------------------------------- //
  private void initCameras( PApplet parent ) {
    // Called by set active project to init saved camera settings for all cameras
    for( Camera camera : cameras ) {
      camera.unregister( camera_map );
    }
  }
  // ---------------------------------------------------------------------------------------- //
  public void addCamera( Camera cam ) {
    cameras.add( cam );
    Project active_project = getActiveProject();
    if( active_project != null ) {
      if( !active_project.hasActiveCamera() )
        active_project.setActiveCamera( this, cameras.size() - 1 );
    }
  }
  // ---------------------------------------------------------------------------------------- //
  public void setActiveCamera( int index ) {
    Project active_project = getActiveProject();
    if( active_project != null ) {
      active_project.setActiveCamera( this, index );
    }
  }
  // ---------------------------------------------------------------------------------------- //
  public Camera getActiveCamera() {
    Project active_project = getActiveProject();
    if( active_project != null ) {
      return active_project.getActiveCamera( this );
    }
    return null;
  }
  // ---------------------------------------------------------------------------------------- //
  public Vector<Camera> getCameras() { return cameras; }
  
  // ---------------------------------------------------------------------------------------- //
  public void loadRootProjects() {
    // Load all the available projects
    projects.clear();
    List<File> project_folders = new ArrayList<File>();
    selectFiles( project_folders, new File( root_folder ), null, false );
    for( File project_folder : project_folders ) {
      Project       p = new Project();
                    p.init( project_folder );
      projects.add( p );
    }
  }
  public List<Project> getProjects() { return projects; }
  // ---------------------------------------------------------------------------------------- //
  public Project getActiveProject() {
    if( hasActiveProject() ) {
      return projects.get( active_project );
    }
    return null;
  }
  // ---------------------------------------------------------------------------------------- //
  public boolean isActiveProject( Project prj ) {
    return projects.indexOf( prj ) == active_project;
  }
  // ---------------------------------------------------------------------------------------- //
  public boolean hasActiveProject() {
    return active_project >= 0;
  }
  // ---------------------------------------------------------------------------------------- //
  public void setActiveProject( PApplet parent, Project prj ) {
    int new_active_project = projects.indexOf( prj );
    if( new_active_project >= 0 ) {
      active_project = new_active_project;
      initCameras( parent );
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
    
    Project       active_project = new Project();
                  active_project.init( project_folder );
    projects.add( active_project );
    this.active_project = projects.size() - 1;
  }
  
  // ---------------------------------------------------------------------------------------- //
  void deleteProject( Project prj ) {
    
    int project_index = projects.indexOf( prj );
    if( active_project == project_index )
        active_project = -1;
    else if( active_project > project_index )
        --active_project;
        
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
}
