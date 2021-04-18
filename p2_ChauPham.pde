import g4p_controls.*;
import controlP5.*;
import processing.sound.*;

SoundFile sound_button, sound_finish;

ControlP5 controlP5;
Knob knob_power_level;
int knob_x = 170;
int knob_y = 140;
int knob_radius = 60;
String text_power_level = "Power level: ";

// Declare some buttons for the interface
GImageButton[] gimagebtn_digit_buttons = new GImageButton[9]; // 9 digit buttons
GImageButton gimagebtn_stop_btn, gimagebtn_30s_btn; // other buttons

PImage[] pimage_screens_display = new PImage[4]; // 4 digits in the LCD screen
PImage[] pimage_screen_image = new PImage[10]; // 10 possible digits which can be shown in the LCD screen
PImage colon;
int colon_x = 190;
int colon_y = 50;
int colon_width = 20;
int colon_height = 50;
int digit_width = 40;
int screen_y = colon_y, screen_height = colon_height;
  

int space_btw_row = 80;
int space_btw_col = 90;
int x_start_btn = 80;
int y_start_btn = 250;
int btn_size= 50;

int microwave_size = 1000;
int count_time = 0;

boolean is_running = false;
color[] power_level_colors = new color[]{color(255,255,204), color(255,255,153), color(255,255,102), color(255,255,51), color(255,255,0)};
int power_color=2; 
void setup() {
// Set up the size for microwave interface
  size(1400, 600);
  
// Set 1 frame per second  
  frameRate(1);
  
// sound effects
  sound_button = new SoundFile(this, "sound/microwave_btn.mp3");
  sound_finish = new SoundFile(this, "sound/microwave_finished.wav");
  
  smooth();
  
// Create a knob for power level
  controlP5 = new ControlP5(this);
  knob_power_level = controlP5.addKnob("knob",100,200,180,knob_x+microwave_size,knob_y,knob_radius);
  knob_power_level.setCaptionLabel("Power level")
    .setNumberOfTickMarks(10)
    .snapToTickMarks(true)
    .setColorForeground(color(255))
    .setColorBackground(color(0, 160, 100))
    .setColorActive(color(255,255,0))
    .setColorValue(color(0, 160, 100));

knob_power_level.getCaptionLabel().setColor(color(3, 157, 252) ).setSize(13);

// Draw 9 buttons (1->9) as a 3x3 matrix.
  for (int i=0; i<9;i++){
    String name = "btn/" + (i+1);
    String original_name = name + ".png";
    String highlighted_name = name + "_highlight.png";

    String[] img_name =  new String [] {original_name, original_name, highlighted_name} ;
    gimagebtn_digit_buttons[i] = new GImageButton(this, microwave_size+x_start_btn + space_btw_col * (i%3),
              y_start_btn + space_btw_row * (i/3), btn_size, btn_size, img_name);
  }

            
            
// Load screen digits
  for (int i=0; i<10; i++){
    pimage_screen_image[i] = loadImage("screen/" + i + ".png");
  }
  colon = loadImage("screen/colon.png");

// init pimage_screens_display to all 0(s)
for (int i=0; i<4; i++){
    pimage_screens_display[i] = pimage_screen_image[0];
}


// Draw stop btn
  gimagebtn_stop_btn = new GImageButton(this, microwave_size+x_start_btn, y_start_btn +space_btw_row * 3.3,
                          btn_size, btn_size, new String [] {"btn/stop.png","btn/stop.png", "btn/stop_highlight.png"} );
                          
// Draw 30s btn
  gimagebtn_30s_btn = new GImageButton(this, microwave_size+x_start_btn+space_btw_col, y_start_btn +space_btw_row * 3.3,
                          btn_size, btn_size, new String [] {"btn/30s.png", "btn/30s.png", "btn/30s_highlight.png"} );
                          
// Backgound
  background(200);
  fill(50);      
 
  
// LCD Screen to display time
  fill(225, 225, 225); 
  rect(microwave_size+110, 50, 180, 50); 
  
  
// microwave  body
  fill(225, 225, 225); //outter
  rect(10, 10, microwave_size-20, 580); 
  
  fill(235, 235, 235); // inner
  rect(50, 50, microwave_size-100, 500); 


// control_body
  fill(225, 225, 225); 
  rect(microwave_size+10, 10, 380, 580); 
  

  fill(50);      

      
  textSize(13); 
  text("Press any +button to ADD TIME & START!", microwave_size+x_start_btn+space_btw_col*2, y_start_btn +space_btw_row * 3, 90, 90);
  
// Add guide for the knob
  textSize(16); 
  text("-", microwave_size+knob_x - 25, knob_radius + knob_y + 15);
  text("0", microwave_size+knob_x - 10, knob_radius + knob_y );

  text("+", microwave_size+knob_x + knob_radius+10,  knob_radius + knob_y + 15);
  text("10", microwave_size+knob_x + knob_radius,  knob_radius + knob_y );

  
//Add items for the screen 
  image(colon,microwave_size+colon_x,colon_y,colon_width,colon_height); //colon
  for (int i=0; i<4; i++){
      image(pimage_screens_display[i],microwave_size+colon_x + (i-2) * digit_width + int(i>=2)* colon_width, screen_y, digit_width, screen_height); 
  }
}

void draw() {
  
  if (count_time == 0){
    if (is_running){
      sound_finish.play();
      change_screen_display(pimage_screens_display, pimage_screen_image, count_time);
      is_running = false;
     
       // stop sound
       //todo
     
      draw_handle();
    }
  
    add_light_when_microwave_running(false);

    draw_handle();
    
  }
  else{
    if (count_time < 0){
       return; 
    }
    else{
      change_screen_display(pimage_screens_display, pimage_screen_image, count_time);
      add_light_when_microwave_running(true);
      draw_handle();
      count_time--;   // minus 1 second from the timer 
    }
  }
   
   
   
}

//// Logic functions -------
String[] get_4_digits_from_current_time(int cur_time){
  String[] res = new String[4];
  int minutes = cur_time/60;
  int seconds = cur_time%60;

  if (minutes > 9){
    res[0] = str(minutes/10);
    res[1] = str(minutes%10);
  }
  else{
    res[0] = "0";
    res[1] = str(minutes);
  }

  res[2] = str(seconds/10);
  res[3] = str(seconds%10);

  return res;
}

boolean change_screen_display(PImage[] pimage_screens_display, PImage[] pimage_screen_image, int cur_time){
  String[] str_4_digits = get_4_digits_from_current_time(cur_time);
  for (int i=0; i<4; i++){
    pimage_screens_display[i] = pimage_screen_image[int(str_4_digits[i])];
  }

  draw_digits_for_the_screen(pimage_screens_display);
  return true;
}


boolean add_light_when_microwave_running(boolean is_running){
  if (is_running){
     fill(power_level_colors[power_color]);
  }
  else{
      fill(235, 235, 235);
  }
  
  rect(50, 50, microwave_size-100, 500); 

  return true;
}

boolean draw_digits_for_the_screen(PImage[] pimage_screens_display){
  for (int i=0; i<4; i++){
      image(pimage_screens_display[i],microwave_size+colon_x + (i-2) * digit_width + int(i>=2)* colon_width, screen_y, digit_width, screen_height); 
  }
  return true;
}


boolean draw_handle(){
 // Microwave handle
  strokeWeight(3);
  line(400+490, 210, 400+507, 200);
  line(400+507, 200, 400+507, 300+150);
  line(400+490, 290+150, 400+507, 300+150); 
  return true;
}

//// Event Handlers -------
// Handle the event when the buttons were clicked
void handleButtonEvents(GImageButton button, GEvent event) {
// Only handle the "click" event
  if (event != GEvent.CLICKED){
    return;
  }
  
  sound_button.play(); //play sound effect


  if (button == gimagebtn_30s_btn) {
      count_time += 30; // add 30s to the current countdown
      is_running = true;
  }
  else if (button == gimagebtn_stop_btn) {
      count_time = 0; // reset the current countdown
            change_screen_display(pimage_screens_display, pimage_screen_image, count_time);
            is_running=false;

  }
  else{
    for (int i =0; i<9; i++){
      if (button == gimagebtn_digit_buttons[i] ) {
        count_time += (i+1)*60; // add "x" minute(s) when pressing "+x" button
        is_running = true;
      }
    }
  }
  
}

// Handler when the knob was turned
void knob(int theValue) {
    int power_level =theValue/10-10;
    if ( power_level<6 ){
      power_color = 1;
    }
    else{
      power_color = power_level- 6;
      
    }
}
