import g4p_controls.*;
import controlP5.*;
import processing.sound.*;

SoundFile sound_button, sound_finish;

ControlP5 controlP5;
Knob knob_speed_level;
int knob_x = 50;
int knob_y = 250;
int knob_radius = 80;
String text_speed_level = "Speed: ";

int speed_level=0;

// Declare some buttons for the interface
GImageButton[] gimagebtn_digit_buttons = new GImageButton[7]; // 
GImageButton gimagebtn_head_light_low, gimagebtn_head_light_hight;
GImageButton gimagebtn_check_engine, gimagebtn_tire_pressure;
GImageButton gimagebtn_seat_belt, gimagebtn_brake;
GImageButton gimagebtn_open_door, gimagebtn_PRND;
GImageButton gimagebtn_fuel;


GImageButton gimagebtn_control_turn_left, gimagebtn_control_turn_right;
GImageButton gimagebtn_control_light;
GImageButton[] gimagebtn_control_prnd = new GImageButton[4];

String[] bottom_icons = new String[]{"headlight.jpeg", "check_engine.jpeg", "tire_pressure.png", "seat_belt.png", "brake_2.jpeg", "open_door.png", "p_prnd.jpg"};



PImage[] pimage_screens_display = new PImage[4]; // 4 digits in the LCD screen
PImage[] pimage_screen_image = new PImage[10]; // 10 possible digits which can be shown in the LCD screen

PImage pimage_turn_left, pimage_turn_right;

PImage colon;
int colon_x = 190;
int colon_y = 50;
int colon_width = 20;
int colon_height = 50;
int digit_width = 40;
int screen_y = colon_y, screen_height = colon_height;
  
int btn_size= 50;
int space_btw_row = btn_size+ 30;
int x_start_btn = 30;
int y_start_btn = 360;


int dashboard_size = 600;
int count_time = 0;

boolean is_running = false;
color[] speed_level_colors = new color[]{color(255,255,204), color(255,255,153), color(255,255,102), color(255,255,51), color(255,255,0)};
int speed_color=2; 
int size_x = 800;
int size_y = 450;

int gauge_x = 250, gauge_y = 200, gauge_radius =280;
int gauge_inner_radius = 240;

 int control_left_x = 630, control_left_y=50;


void setup() {
// Set up the size for dashboard interface

  size(800, 450);
  
 
  
// Set 1 frame per second  
  frameRate(1);
  
// sound effects
  //sound_button = new SoundFile(this, "sound/dashboard_btn.mp3");
  //sound_finish = new SoundFile(this, "sound/dashboard_finished.wav");
  
  smooth();
  
// Create a knob for speed level
  controlP5 = new ControlP5(this);
  knob_speed_level = controlP5.addKnob("knob",0,200,50,knob_x+dashboard_size,knob_y,knob_radius);
  knob_speed_level.setCaptionLabel("speed (mph)")
    .setNumberOfTickMarks(10)
    .snapToTickMarks(true)
    .setColorForeground(color(255))
    .setColorBackground(color(200))
    .setColorActive(color(255,255,0))
    .setColorValue(color(0, 160, 100));

knob_speed_level.getCaptionLabel().setColor(color(20) ).setSize(13);


// Draw bottom buttons 
  for (int i=0; i<bottom_icons.length;i++){
    String original_name = "icons/" + bottom_icons[i];
    String highlighted_name = original_name + "_highlight.png";

    // String[] img_name =  new String [] {original_name, original_name, highlighted_name} ;
    gimagebtn_digit_buttons[i] = new GImageButton(this, x_start_btn + space_btw_row * i,
              y_start_btn , btn_size, btn_size, new String [] {original_name});
  }
  
  
// Draw control buttons 
 gimagebtn_control_turn_left = new GImageButton(this, control_left_x, control_left_y , btn_size, btn_size, new String [] {"control_btns/turn_left.png"});
 gimagebtn_control_turn_right = new GImageButton(this, control_left_x+ space_btw_row, control_left_y , btn_size, btn_size, new String [] {"control_btns/turn_right.png"});

 gimagebtn_control_light = new GImageButton(this, control_left_x+ 30, control_left_y + space_btw_row, btn_size+20, btn_size+20, new String [] {"control_btns/headlight.png"});
 // Draw PRND buttons 
 String[] prnd_names = new String[]{"p", "r", "n", "d"};
  for (int i=0; i<prnd_names.length; i++){
    String original_name = "control_btns/" + prnd_names[i] + ".png";
    String highlighted_name = original_name + "_highlight.png";

    // String[] img_name =  new String [] {original_name, original_name, highlighted_name} ;
    gimagebtn_control_prnd[i] = new GImageButton(this, control_left_x-10+ space_btw_row/2 * i,
              y_start_btn+15 , btn_size/1.5, btn_size/1.5, new String [] {original_name});
  }
            
      
// Load turn left & right icons
  pimage_turn_left = loadImage("icons/turn_left.png" );
  pimage_turn_right = loadImage("icons/turn_right.png" );
 
   
// Backgound
  background(200);
  fill(50);      

  
  
// dashboard  body
  fill(225, 225, 225); //outter
  rect(10, 10, dashboard_size-20, size_y-20); 
  

// control (simulation) body
  fill(225, 225, 225); 
  rect(dashboard_size+10, 10, size_x - dashboard_size - 30 , size_y-20); 
  

  fill(40);      

        
// Add guide for the knob
  textSize(16); 
  text("0", dashboard_size+knob_x - 10, knob_radius + knob_y );
  text("200", dashboard_size+knob_x + knob_radius,  knob_radius + knob_y );

  
//Add turn left, right icons to the dashboard 
 image(pimage_turn_left,40, 150, 50,50); 
 image(pimage_turn_right,400, 150, 50,50); 
 
   fill(240);      

// Gauge

stroke(100);
circle(gauge_x, gauge_y, gauge_radius);
   

//arc(gauge_x, gauge_y, gauge_inner_radius,gauge_inner_radius, 0, PI, OPEN);

   int rpm_bar_x=500, rpm_bar_y = 100, rpm_bar_width = 30,  rpm_bar_height = 200;
  fill(100);
  rect(rpm_bar_x, rpm_bar_y, rpm_bar_width, rpm_bar_height);
  fill(255);

  rect(rpm_bar_x, rpm_bar_y, rpm_bar_width, rpm_bar_height-30);

 fill(30);
    textSize(20); 
    text("RPM" , rpm_bar_x-6, rpm_bar_y-10);
    

}

void draw() {
  
  
 
  

  
  
  fill(250);  
   
   
stroke(245);
arc(gauge_x, gauge_y, gauge_inner_radius,gauge_inner_radius, PI*0.8, TWO_PI*1.1, OPEN);

    fill(30);
    textSize(60); 
    text(speed_level , gauge_x - 40 - int(speed_level>100)*25, gauge_y-10);
    
    fill(30);
    textSize(16); 
    text("MPH" , gauge_x + 30, gauge_y+10);
    

  
}

//// Logic functions -------
boolean plot_button(int x,int y,int w,int h,int r, int fill_color, String text, int text_size){
  
   rect(x, y, w, h, r);
    fill(fill_color);
    textAlign(CENTER,CENTER);
    textSize(text_size);
    text(text, x+(w/2), y+(h/2));
    
    return true;


 
}

boolean add_light_when_dashboard_running(boolean is_running){
  if (is_running){
     fill(speed_level_colors[speed_color]);
  }
  else{
      fill(235, 235, 235);
  }
  
  rect(50, 50, dashboard_size-100, 500); 

  return true;
}


//// Event Handlers -------
// Handle the event when the buttons were clicked
void handleButtonEvents(GImageButton button, GEvent event) {
// Only handle the "click" event
    print("clicked!");

  if (event != GEvent.CLICKED){
    return;
  }
  
  //sound_button.play(); //play sound effect


  //if (button == gimagebtn_30s_btn) {
  //    count_time += 30; // add 30s to the current countdown
  //    is_running = true;
  //}
  //else if (button == gimagebtn_stop_btn) {
  //    count_time = 0; // reset the current countdown
  //          change_screen_display(pimage_screens_display, pimage_screen_image, count_time);
  //          is_running=false;

  //}
  //else{
  //  for (int i =0; i<9; i++){
  //    if (button == gimagebtn_digit_buttons[i] ) {
  //      count_time += (i+1)*60; // add "x" minute(s) when pressing "+x" button
  //      is_running = true;
  //    }
  //  }
  //}
  
}

// Handler when the knob was turned
void knob(int theValue) {
    speed_level = theValue;

    
}
