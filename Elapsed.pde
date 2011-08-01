/***|  |*********|   |***************************************************************************************************
/*  |___ Elapsed has configuration, setup, draw and event entry points                                                  *
/*               |____ Camera                                                                                           *
/*                                                                                                                      *
/*                                                                                                                      *
/*                                                                                                                      *
/************************************************************************************************************************/
import java.util.Vector;
import java.awt.Color;
import com.sun.awt.AWTUtilities;
import javax.swing.JOptionPane;


public static final int           SELECT_PROJECT_MODE  = 0;
public static final int           CONFIG_MODE          = 1;
public static final int           STOP_MOTION_MODE     = 2;
public static final int           TIME_LAPSE_MODE      = 3;


private String                    slash          = "/";
private String                    root_folder    = "";
private String                    project_name   = "Project";
private Vector<Camera>            cameras        = new Vector<Camera>();
private HashMap<Capture, Camera>  camera_map     = new HashMap<Capture, Camera>();
private Camera                    active_cam     = null;
private Project                   active_project = null;
private Project                   delete_project = null;
private ArrayList<Project>        projects       = new ArrayList<Project>();

private PFont                     title_font     = null;
private PFont                     display_font   = null;
private int                       font_size      = 14;
private int                       mode           = SELECT_PROJECT_MODE;


private float                     title_x        = 0;
private float[]                   bg_line_ang    = null;
private float[]                   bg_line_size   = new float[] { 1,1,2,3,1,1,1,5,8 };
float                             ang;

private Clickable                 ui_root_folder;
private Clickable                 ui_back;
private Clickable                 ui_next;
private Clickable                 ui_name;
private Clickable                 ui_resolution;
private Clickable                 ui_frame_time;

private Clickable                 ui_new_project;

private Loader                    loader;


    

// ---------------------------------------------------------------------------------------- //
void setup() {
  
  size       ( 800, 600, P3D );
  frameRate  ( 60 );
  background ( 64 );

  frame.setResizable            ( true );
  frame.setTitle                ( " | Elapsed 001 | Project Configuration" );
  frame.setAlwaysOnTop          ( false );  
  AWTUtilities.setWindowOpacity ( frame, 0.95f  );
  
  title_x      = width;
  title_font   = createFont ( "Arial", 200, true );
  display_font = createFont ( "Arial", font_size, false ); 
                 textMode   ( SCREEN );
  
  initAppSettings();

  // Start initializing the active cameras
  loader = new Loader( this );
  loader.start();
  
  // Initialize the UI components for the app
  ui_root_folder = new Clickable( root_folder, false );
  ui_back        = new Clickable( "Back",      true  );
  ui_next        = new Clickable( "Next",      true  );
  ui_name        = new Clickable( "",          false );
  ui_resolution  = new Clickable( "",          false );
  ui_frame_time  = new Clickable( "",          false );
  
  ui_new_project = new Clickable( "New Project", true );
  
  PGraphics graphics = createGraphics(180,120,P2D);
  graphics.beginDraw();
  graphics.noStroke();
  graphics.fill(32);
  graphics.ellipse(90,60,110,110);
  graphics.fill(64);
  graphics.translate(90,60);
  graphics.pushMatrix();
    graphics.rect(0,-10,40,20);
    graphics.rotate( radians(90) );
    graphics.rect(0,-10,40,20);
    graphics.rotate( radians(90) );
    graphics.rect(0,-10,40,20);
    graphics.rotate( radians(90) );
    graphics.rect(0,-10,40,20);
  
  graphics.popMatrix();
  graphics.endDraw();
  ui_new_project.img = graphics.get();
 

  // Initialize the background line visuals data
  bg_line_ang = new float[ bg_line_size.length ];
  for( int i=0; i<bg_line_ang.length; ++i )
    bg_line_ang[i] = random(0,PI);
  
  if( System.getProperty("os.name").contains( "Windows" ) ) {
    File vdig_elem = new File( "C:\\Windows\\System32\\QuickTime\\VsVDIG.qtx" );
    if( !vdig_elem.exists() ) {
      open( dataPath("WinVDIG_101.exe") );
      exit();
    }
  }
}

// ---------------------------------------------------------------------------------------- //
void draw()
{
  if( delete_project != null ) {
    deleteProject( delete_project );
    delete_project = null;
  }
  background( #313739 );
  draw_bg_lines();
  
  if      ( mode == SELECT_PROJECT_MODE ) draw_select_project();
  else if ( mode == CONFIG_MODE         ) draw_config();
  else if ( mode == STOP_MOTION_MODE    ) draw_stopmotion();
  else if ( mode == TIME_LAPSE_MODE     ) draw_timelapse();
}

// ---------------------------------------------------------------------------------------- //
void mousePressed() {
  if      ( ui_root_folder.clicked() ) {
    if      ( mouseButton == LEFT  ) {
      String selected = selectFolder();
      if( selected != null ) {
        root_folder = selected;
        File root_folder_file = new File( root_folder );
        if( !root_folder_file.exists() ) root_folder_file.mkdir();
        ui_root_folder.name = root_folder;
      }
    }
  }
  else if ( ui_back.clicked() ) back();
  else if ( ui_next.clicked() ) next();
  else if ( ui_name.clicked() );
  else if ( ui_resolution.clicked() && active_cam != null ) {
    if      ( mouseButton == LEFT  ) ++active_cam.resolution;
    else if ( mouseButton == RIGHT ) --active_cam.resolution;
    active_cam.resolution += resolutions.length;
    active_cam.resolution %= resolutions.length;
    
    camera_map.remove( active_cam.source );
    active_cam.source.dispose();
    active_cam.source = null;
   }
  else if ( ui_frame_time.clicked() && active_cam != null ) {
    if      ( mouseButton == LEFT  ) ++active_cam.frame_time;
    else if ( mouseButton == RIGHT ) --active_cam.frame_time;
    active_cam.frame_time += frame_times.length;
    active_cam.frame_time %= frame_times.length;
    

  }
  else if ( ui_new_project.clicked() ) {
    if( mouseButton == LEFT  ) newProject();
  }
  //else if ( ui_.clicked() )
  //else if ( ui_.clicked() )
  else {
    for( Camera cam : cameras ) {
      boolean   clicked = cam.ui.clicked();
      if      ( clicked && mouseButton == LEFT  ) active_cam = cam;
      else if ( clicked && mouseButton == RIGHT ) cam.source.settings();
    }
    
    for( Project prj : projects ) {
      boolean   clicked = prj.ui.clicked();
      if      ( clicked && mouseButton == LEFT  ) active_project = prj;
      else if ( clicked && mouseButton == RIGHT ) delete_project = prj;
    }
  }
}

// ---------------------------------------------------------------------------------------- //
void back() {
  if      ( mode == SELECT_PROJECT_MODE ) exit();
  else if ( mode == CONFIG_MODE         ) mode = SELECT_PROJECT_MODE;
  //else if ( mode == STOP_MOTION_MODE    ) mode = CONFIG_MODE;
  else if ( mode == TIME_LAPSE_MODE     ) mode = CONFIG_MODE;
}

// ---------------------------------------------------------------------------------------- //
void next() {
  if      ( mode == SELECT_PROJECT_MODE ) mode = CONFIG_MODE;
  else if ( mode == CONFIG_MODE         ) {
       if ( active_project == null      ) newProject();
    mode = TIME_LAPSE_MODE;
  }
  //else if ( mode == STOP_MOTION_MODE    ) mode = SELECT_PROJECT_MODE;
  else if ( mode == TIME_LAPSE_MODE     ) mode = SELECT_PROJECT_MODE;
}




// ---------------------------------------------------------------------------------------- //
void captureEvent( Capture which ) {
  if( camera_map.size() > 0 ) {
    Camera which_cam = camera_map.get( which );
           which_cam.capture();
  }
}



// ---------------------------------------------------------------------------------------- //
void logMessage( String message ) { println( message ); }
