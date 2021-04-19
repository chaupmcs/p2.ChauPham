    import g4p_controls.*;
    import controlP5.*;
    import processing.sound.*;

    SoundFile sound_button, sound_turn, sound_car_engine;

    ControlP5 controlP5;
    Knob knob_speed_level;
    int knob_x = 50;
    int knob_y = 250;
    int knob_radius = 80;
    String text_speed_level = "Speed: ";

    int previous_rpm_level = 60;
    int speed_level = 0;
    int rpm_level=1;
    int rpm_bar_x = 500, rpm_bar_y = 100, rpm_bar_width = 30, rpm_bar_height = 200;


    boolean left_blinker = false, right_blinker = false;
    // Declare some buttons for the interface
    GImageButton[] gimagebtn_bottom_buttons = new GImageButton[7]; // 
    GImageButton gimagebtn_head_light_low, gimagebtn_head_light_hight;
    GImageButton gimagebtn_check_engine, gimagebtn_tire_pressure;
    GImageButton gimagebtn_seat_belt, gimagebtn_brake;
    GImageButton gimagebtn_open_door, gimagebtn_PRND;
    GImageButton gimagebtn_fuel;

    GImageButton gimagebtn_control_turn_left, gimagebtn_control_turn_right;
    GImageButton gimagebtn_control_light;
    GImageButton[] gimagebtn_control_prnd = new GImageButton[4];

    String[] bottom_icons = new String[] {
      "headlight.jpeg",
      "check_engine.png",
      "tire_pressure.png",
      "seat_belt.png",
      "brake_2.jpeg",
      "open_door.png",
      "p_prnd.jpg"
    };

    int[] bottom_icons_on = new int[] {0,0,0,0,0,0,0};


    PImage pimage_turn_left, pimage_turn_right, pimage_headlight;
    PImage pimage_turn_right_highlight, pimage_turn_left_highlight, pimage_headlight_highlight;
    PImage pimage_turn_right_transparent, pimage_turn_left_transparent, pimage_headlight_transparent;


    String[] image_prnd_list = new String[]{"icons/P.png", "icons/R.png", "icons/N.png", "icons/D.png"};

    PImage pimage_prnd, pimage_fuel;

    int btn_size = 50;
    int space_btw_row = btn_size + 30;
    int x_start_btn = 30;
    int y_start_btn = 360;

    int dashboard_size = 600;
    int count_time = 0;

    boolean is_running = false;
    color[] speed_level_colors = new color[] {
      color(255, 255, 204), color(255, 255, 153), color(255, 255, 102), color(255, 255, 51), color(255, 255, 0)
    };
    int speed_color = 2;
    int size_x = 800;
    int size_y = 450;

    int gauge_x = 250, gauge_y = 200, gauge_radius = 280;
    int gauge_inner_radius = 240;

    int control_left_x = 630, control_left_y = 50;

    void setup() {
      
      // Set up the size for dashboard interface
      size(800, 450);

      // Set 1 frame per second  
      frameRate(1);

      // sound effects
      sound_button = new SoundFile(this, "sounds/btn_click.mp3");
      sound_turn = new SoundFile(this, "sounds/car_turn_indicator.mp3");
      sound_car_engine = new SoundFile(this, "sounds/car_engine.mp3");
      smooth();

      // Create a knob for speed level
      controlP5 = new ControlP5(this);
      knob_speed_level = controlP5.addKnob("knob", 0, 200, 50, knob_x + dashboard_size, knob_y, knob_radius);
      knob_speed_level.setCaptionLabel("speed (mph)")
        .setNumberOfTickMarks(5)
        .snapToTickMarks(true)
        .setColorForeground(color(255))
        .setColorBackground(color(56,105,196))
        .setColorActive(color(255, 255, 0))
        .setColorValue(color(56,105,196));

      knob_speed_level.getCaptionLabel().setColor(color(20)).setSize(11);

      

      // Draw control buttons 
      gimagebtn_control_turn_left = new GImageButton(this, control_left_x, control_left_y, btn_size, btn_size, new String[] {
        "control_btns/turn_left.png"
      });
      gimagebtn_control_turn_right = new GImageButton(this, control_left_x + space_btw_row, control_left_y, btn_size, btn_size, new String[] {
        "control_btns/turn_right.png"
      });

      gimagebtn_control_light = new GImageButton(this, control_left_x + 30, control_left_y + space_btw_row, btn_size + 20, btn_size + 20, new String[] {
        "control_btns/headlight.png"
      });
      // Draw PRND buttons 
      String[] prnd_names = new String[] {
        "p",
        "r",
        "n",
        "d"
      };
      for (int i = 0; i < prnd_names.length; i++) {
        String original_name = "control_btns/" + prnd_names[i] + ".png";
        gimagebtn_control_prnd[i] = new GImageButton(this, control_left_x - 10 + space_btw_row / 2 * i,
          y_start_btn + 15, btn_size / 1.5, btn_size / 1.5, new String[] {
            original_name
          });
      }

      // Load turn left & right icons
      pimage_turn_left_highlight = loadImage("icons/turn_left.png");
      pimage_turn_right_highlight = loadImage("icons/turn_right.png");
      pimage_headlight_highlight =  loadImage("icons/headlight.jpeg");

      pimage_turn_left_transparent = loadImage("icons/turn_left_transparent.png");
      pimage_turn_right_transparent = loadImage("icons/turn_right_transparent.png");
      pimage_headlight_transparent =  loadImage("icons/headlight_transparent.png");


      pimage_turn_left = pimage_turn_left_transparent;
      pimage_turn_right = pimage_turn_right_transparent;
      pimage_headlight = pimage_headlight_transparent;

      // Backgound
      background(200);
      fill(50);

      // dashboard  body
      fill(225, 225, 225); //outter
      rect(10, 10, dashboard_size - 20, size_y - 20);

      // control (simulation) body
      fill(225, 225, 225);
      rect(dashboard_size + 10, 10, size_x - dashboard_size - 30, size_y - 20);

      fill(40);

      // Add guide for the knob
      textSize(16);
      text("0", dashboard_size + knob_x - 10, knob_radius + knob_y);
      text("200", dashboard_size + knob_x + knob_radius, knob_radius + knob_y);

      fill(0);

      // Gauge
      stroke(255);
      circle(gauge_x, gauge_y, gauge_radius);


      fill(100);
      rect(rpm_bar_x, rpm_bar_y, rpm_bar_width, rpm_bar_height);
      //fill(60);

      //rect(rpm_bar_x, rpm_bar_y, rpm_bar_width, rpm_bar_height - 60);

      fill(0);
      textSize(20);
      text("RPM", rpm_bar_x - 6, rpm_bar_y - 10);
      
      pimage_prnd= loadImage(image_prnd_list[0]);
      
      draw_bottom_buttons();
      
      
      strokeWeight(10);
      stroke(80);
      arc(gauge_x, gauge_y, gauge_inner_radius,gauge_inner_radius, PI*0.3, PI*0.6, OPEN);
      
      //fill(color(255,0,0));
      //textSize(20);
      //text("E", 170, 290);
      
      stroke(color(0,204,102));
      arc(gauge_x, gauge_y, gauge_inner_radius,gauge_inner_radius, PI*0.6, PI*0.7, OPEN);


      fill(color(0,204,102));
      textSize(20);
      text("F", 320, 290);
      
      
      strokeWeight(1);


      pimage_fuel = loadImage("icons/fuel_pump.png");
      image(pimage_fuel, 230, 275, btn_size*0.7, btn_size*0.7);
      



    }
    void draw() {

      fill(40);

      stroke(245);
      strokeWeight(4);
      arc(gauge_x, gauge_y, gauge_inner_radius, gauge_inner_radius, PI * 0.8, TWO_PI * 1.1, OPEN);

      strokeWeight(1);

      fill(255);
      textSize(60);
      text(speed_level, gauge_x - 40 - int(speed_level > 100) * 25, gauge_y - 10);

      textSize(16);
      text("MPH", gauge_x + 30, gauge_y + 10);

      //Add turn left, right icons to the dashboard 
      image(pimage_turn_left, 40, 150, 50, 50);
      image(pimage_turn_right, 400, 150, 50, 50);
      image(pimage_headlight, x_start_btn , y_start_btn, btn_size, btn_size);
      image(pimage_prnd, x_start_btn + 6*space_btw_row , y_start_btn, btn_size, btn_size);

      fill(color(40));
      rect(rpm_bar_x, rpm_bar_y, rpm_bar_width, rpm_bar_height);
      fill(150);
      rect(rpm_bar_x, rpm_bar_y, rpm_bar_width, rpm_bar_height - rpm_level);

      draw_blinker();
    }


//------------------------

    
    //// Logic functions -------
    
    void draw_blinker(){
      if (left_blinker){
        pimage_turn_left = toggle_pimg_status(pimage_turn_left, pimage_turn_left_highlight, pimage_turn_left_transparent);
      }
      if (right_blinker){
          pimage_turn_right = toggle_pimg_status(pimage_turn_right, pimage_turn_right_highlight, pimage_turn_right_transparent);

      }
      
    }

    boolean draw_bottom_buttons(){
     // Draw bottom buttons 
      for (int i = 1; i < bottom_icons.length-1; i++) {

        String[] name_and_extension = bottom_icons[i].split("\\.");
        String name = ""; 
        if (bottom_icons_on[i] == 0){
            name = "icons/" + name_and_extension[0] + "_transparent.png";
        }
        else{
            name = "icons/" + bottom_icons[i];
        }
        gimagebtn_bottom_buttons[i] = new GImageButton(this, x_start_btn + space_btw_row * i,
          y_start_btn, btn_size, btn_size, new String[] {
            name
          });
      }
     return true;
    }
    boolean plot_button(int x, int y, int w, int h, int r, int fill_color, String text, int text_size) {
      rect(x, y, w, h, r);
      fill(fill_color);
      textAlign(CENTER, CENTER);
      textSize(text_size);
      text(text, x + (w / 2), y + (h / 2));

      return true;
    }

    boolean add_light_when_dashboard_running(boolean is_running) {
      if (is_running) {
        fill(speed_level_colors[speed_color]);
      } else {
        fill(235, 235, 235);
      }

      rect(50, 50, dashboard_size - 100, 500);

      return true;
    }

    PImage toggle_pimg_status(PImage cur, PImage status_a, PImage status_b) {
      if (cur == status_a) {
        return status_b;
      }
      return status_a;

    }



    //// Event Handlers -------
    // Handle the event when the buttons were clicked
    void handleButtonEvents(GImageButton button, GEvent event) {
      // Only handle the "click" event
      print("clicked!");

      if (event != GEvent.CLICKED) {
        return;
      }

      sound_button.play(); //play sound effect

      if (button == gimagebtn_control_turn_right) {
        if (right_blinker){
          sound_turn.stop();
          pimage_turn_right = pimage_turn_right_transparent;
        }
        else{
          pimage_turn_right = pimage_turn_right_highlight;
           sound_turn.play();
        }        
        right_blinker = !right_blinker;
      } else if (button == gimagebtn_control_turn_left) {
        if (left_blinker){
          pimage_turn_left = pimage_turn_left_transparent;
          sound_turn.stop();
        }
        else{
          pimage_turn_left = pimage_turn_left_highlight;
          sound_turn.play();
        }        
        left_blinker = !left_blinker;
      } else if (button == gimagebtn_control_light) {
        pimage_headlight = toggle_pimg_status(pimage_headlight, pimage_headlight_highlight, pimage_headlight_transparent);
      }
        else {
          for (int i=0; i < gimagebtn_control_prnd.length; i++){
              if (button == gimagebtn_control_prnd[i]) {
                  pimage_prnd = loadImage(image_prnd_list[i]);
                  return;
              }
          }

        }
           for (int i=1; i < gimagebtn_bottom_buttons.length-1; i++){
               
              print(gimagebtn_bottom_buttons[i]);
              if (button == gimagebtn_bottom_buttons[i]) {                  
                  bottom_icons_on[i] = 1 - bottom_icons_on[i];
                  draw_bottom_buttons();
                  return;
              }
          }
          
        


    }

    // Handler when the knob was turned
    void knob(int theValue) {
      speed_level = theValue;
      if (theValue - previous_rpm_level>0){
        sound_car_engine.play();
      }
      else{
        sound_car_engine.stop();

      }
      rpm_level = Math.max(theValue - previous_rpm_level,0);
      previous_rpm_level = theValue;
      

    }
