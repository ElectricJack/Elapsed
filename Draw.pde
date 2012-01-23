
// ---------------------------------------------------------------------------------------- //
void draw_select_project() {
  noStroke();
  draw_title("Select Project");

  draw_ui_topleft      ( ui_new_project, 30, 200 );

  int last_x = 30 + (int)ui_new_project.w;
  int last_y = 200;
  for ( Project project : settings.projects ) {

    project.ui.selected = settings.isActiveProject( project );
    draw_ui_topleft ( project.ui, last_x, last_y );

    last_x +=  project.ui.w;
    if ( last_x + project.ui.w > width ) {
      last_x  = 30;
      last_y += 140;
    }
  }

  draw_ui_bottomright  ( ui_root_folder, 30, 5 );
  draw_ui_topleft      ( ui_back, 30, 5 );
  draw_ui_topright     ( ui_next, 30, 5 );
}

int border = 5;
// ---------------------------------------------------------------------------------------- //
void draw_cameras() {

  pushMatrix();

  int x = 30;
  for ( Camera source : settings.getCameras() ) {
    if ( source != null && source.ui != null ) {
      draw_ui_bottomleft( source.ui, x, border );
    }
    x += 100;
  }

  popMatrix();
}
// ---------------------------------------------------------------------------------------- //
void draw_config() {
  noStroke();
  draw_title("Project Configuration");
  int horiz_margin = 30;  

  //draw_cameras();

  Camera active_cam = settings.getActiveCamera();
  if ( active_cam != null ) {
    pushMatrix();
    fill(32);
    float cam_width  = active_cam.getWidth();
    float cam_height = active_cam.getHeight();

    // First we calculate the fixed width of everything that needs to fit across the page,
    //  if that plus the active cam width > the available width, then we should scale down the
    //   camera
    float scalar         = 1.0;
                            textFont  ( display_font );
    float cam_name_width =  textWidth ( active_cam.getName() );
    //println( active_cam.getName() );
    float fixed_width    = 2*horiz_margin + 120 + border + cam_name_width;
    //println( fixed_width );
    if ( fixed_width + cam_width > width ) {
      scalar = (width - fixed_width) / cam_width;
    }

    float nw = scalar*cam_width;
    float nh = scalar*cam_height;

    translate( horiz_margin + border, height*0.5 - nh/2 + border );
    rect( -border, -border, nw + 2*border, nh + 2*border );
    active_cam.draw( 0, 0, nw, nh );
    translate(  nw + 20, 0 );

    
    draw_text ( "Name:" );
    ui_name.name = active_cam.getName();
    draw_ui_topleft( ui_name, 100, 0 );

    translate( 0, 20 );
    draw_text ( "Resolution:" );
    ui_resolution.name = resolutions[ active_cam.resolution ];
    draw_ui_topleft( ui_resolution, 100, 0 );

    translate( 0, 20 );                    
    draw_text ( "Frame time:" );
    ui_frame_time.name = frame_times[ active_cam.frame_time ];
    draw_ui_topleft( ui_frame_time, 100, 0 );

    popMatrix();
  } 
  else {

    fill     ( 60 );
    textFont ( title_font );
    text     ( "Loading", width-textWidth("Loading"), height - 60 );
  }

  draw_ui_bottomright  ( ui_root_folder, horiz_margin, 5 );
  draw_ui_topleft      ( ui_back, horiz_margin, 5 );
  draw_ui_topright     ( ui_next, horiz_margin, 5 );
}



// ---------------------------------------------------------------------------------------- //
void draw_timelapse() {
  noStroke();
  draw_title("Recording...");


  Camera active_cam = settings.getActiveCamera();
  if ( active_cam != null ) {
    int nw, nh;
    if ( active_cam.getHeight() - 40  > height ) {
      nh = height - 40;
      nw = (int)( active_cam.getWidth()*nh / active_cam.getHeight() );
    } 
    else {
      nw = width - 60;
      nh = (int)( active_cam.getHeight()*nw / active_cam.getWidth() );
    }
    active_cam.draw(width*0.5 - nw*0.5, height*0.5 - nh*0.5, nw, nh );
  }

  draw_cameras();

  // Iterate through all the active cameras    
  for ( Camera cam : settings.getCameras() ) {

    // Get the frame time for this source
    int frame_time   = cam.getFrameTime();

    // Now check to see if we actually need to save a frame
    int current_time = millis();
    if ( current_time - cam.last_time > frame_time ) {
      cam.saveImage();      
      cam.last_time = current_time;
    }
  }

  draw_ui_topleft      ( ui_back, 30, 5 );
  draw_ui_topright     ( ui_next, 30, 5 );
}

// ---------------------------------------------------------------------------------------- //
void draw_stopmotion() {
}

// ---------------------------------------------------------------------------------------- //
void draw_bg_lines() {
  ang += 0.0025;
  fill( 255, 5 );
  for ( int i=0; i<bg_line_ang.length; ++i ) {
    float h = bg_line_size[i];
    float y = height*0.5 + sin( bg_line_ang[i] + ang  ) * height * 0.25;
    rect( 0, y - h*5, width, h*10 );
  }
}

// ---------------------------------------------------------------------------------------- //
void draw_title( String title ) {
  textFont ( title_font );
  fill     ( 128 );
  text     ( title, title_x, 150 );

  Project active_project = settings.getActiveProject();
  if ( active_project != null ) {
    frame.setTitle( active_project.getName() + " | " + title + " | Timelapse Capture | 0.0.1" );
    if ( title_x < -textWidth( title ) ) title_x = width; 
    title_x -= 1;
  }
}


// ---------------------------------------------------------------------------------------- //
void draw_button( int x, int y, String name ) {
  textFont ( display_font );
  pushMatrix();
  fill      ( 32 );
  translate ( x, y );
  rect      ( -10, -5, 22 + textWidth( name ), 12 + font_size );
  draw_text ( name );
  popMatrix();
}

// ---------------------------------------------------------------------------------------- //
void draw_text( String what ) {

  int x = (int)screenX( 0, font_size );
  int y = (int)screenY( 0, font_size );

  fill(   0 ); 
  text( what, x + 1, y + 1 );
  fill( 255 ); 
  text( what, x, y );
}

// ---------------------------------------------------------------------------------------- //
void draw_ui_topleft( Clickable ui, int x, int y ) {
  pushMatrix();
  ui.update();
  translate( x, y );
  ui.draw();
  popMatrix();
}

// ---------------------------------------------------------------------------------------- //
void draw_ui_topright    ( Clickable ui, int x, int y ) { 
  draw_ui_topleft( ui, (int)(width - ui.w - x), y );
}
void draw_ui_bottomleft  ( Clickable ui, int x, int y ) { 
  draw_ui_topleft( ui, x, (int)(height - ui.h - y) );
}
void draw_ui_bottomright ( Clickable ui, int x, int y ) { 
  draw_ui_topleft( ui, (int)(width - ui.w - x), (int)(height - ui.h - y) );
}

