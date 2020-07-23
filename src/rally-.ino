//#include "Wire.h"
#include <Arduino.h>
#include <EEPROM.h>
#include <U8g2lib.h>

#ifdef U8X8_HAVE_HW_SPI
#include <SPI.h>
#endif

#define cbi(sfr, bit) (_SFR_BYTE(sfr) &= ~_BV(bit))
#define sbi(sfr, bit) (_SFR_BYTE(sfr) |= _BV(bit))

U8G2_UC1608_240X128_1_4W_SW_SPI
u8g2(U8G2_R0,
     /* clock=*/13,
     /* data=*/11,
     /* cs=*/7,
     /* dc=*/12,
     /* reset=*/8); // SW SPI, Due ERC24064-1 Test Setup

int count;
int cal;
int cum_places = 2;
int int_places = 2;
double cum_rotations = 0;
double int_rotations = 0;
int option = 0;
float cumulative = 0;
float intermediate = 0;
char MENU_ITEMS[5][6] = {{'n', 'u', 'l', 'l'},
                         {'n', 'u', 'l', 'l'},
                         {'n', 'u', 'l', 'l'},
                         {'c', 'a', 'l', 'i'},
                         {'e', 'x', 'i', 't'}};
int hold;
char lastkey;

void get_stored_cal()
{
  EEPROM.get(0, cal);
}

void set_stored_cal(int val)
{
  EEPROM.put(0, val);
}

void reset_counter()
{
  // configure Counter 1
  cbi(TCCR1A, WGM11);
  cbi(TCCR1A, WGM10);
  cbi(TCCR1B, WGM12); // WGM12::WGM10 000 - Normal mode
  sbi(TCCR1B, CS12);  // CS12::CS10 111 - External clock, count on rising edge.
  sbi(TCCR1B, CS11);
  sbi(TCCR1B, CS10);
  TCNT1 = 0x0000; // note that TCNT1 is 16-bits
                  // not sure if should turn off the counter
}

char get_button_pressed()
{
  if ((digitalRead(A1) == LOW)) {
    return 0xB0; // KEY_RETURN;
  } else if ((digitalRead(A0) == LOW)) {
    return 0xD9; // KEY_DOWN_ARROW;
  } else if ((digitalRead(A2) == LOW)) {
    return 0xDA; // KEY_UP_ARROW;
  } else {
    return 0;
  }
}

void drawBorders(void)
{
  u8g2.drawFrame(1, 1, 180, 64);   // boxA
  u8g2.drawFrame(1, 64, 180, 64);  // boxB
  u8g2.drawFrame(180, 1, 60, 127); // boxC
}

void boxA(float val,int digits)
{
  u8g2.setFont(u8g2_font_logisoso54_tn);
  u8g2.setCursor(2,60);
  u8g2.print(val,digits);
}

void boxB(float val,int digits) {
  u8g2.setFont(u8g2_font_logisoso54_tn);
  u8g2.setCursor(2,124);
  u8g2.print(val,digits);
}

void boxC(char text[5][6], int option)
{
  for (int i = 0; i < 5; i++) {
    if (i == option) {
      u8g2.setFont(u8g2_font_fub17_tr);
    } else {
      u8g2.setFont(u8g2_font_fur17_tr);
    }
    u8g2.drawStr(182, (i+1) * 20, text[i]);
  }
}

void setup(void)
{
  // Serial.begin(9600);
  u8g2.begin();
  u8g2.setContrast(10);
  get_stored_cal();
  // Serial.print("Calibration: ");
  // Serial.println(cal);
  pinMode(5, INPUT_PULLUP);
  pinMode(A0, INPUT_PULLUP);
  pinMode(A1, INPUT_PULLUP);
  pinMode(A2, INPUT_PULLUP);
  cum_rotations = 0;
  int_rotations = 0;
}

void update_dist()
{
  int diff = TCNT1;
  reset_counter();
  cum_rotations += TCNT1;
  int_rotations += TCNT1;
  cumulative = (cum_rotations * cal) / 1000000;
  intermediate = (int_rotations * cal) / 1000000;
  cum_places = (cumulative >= 100) ? 1 : 2;
  int_places = (intermediate >= 100) ? 1 : 2;
  if (cumulative >= 999)
    cumulative = 0;
  if (intermediate >= 999)
    intermediate = 0;
};

void menu()
{
  option = 4;
  // Serial.println("In Menu");
  while (option < 6) {
    u8g2.firstPage();
    do {
      drawBorders();
      boxA(cumulative,cum_places);
      //boxB(intermediate,int_places);
      boxC(MENU_ITEMS, option);
    } while (u8g2.nextPage());
    // delay(100);
    char pressed = get_button_pressed();
    switch (pressed) {
    case char(0xD9): {
      option = (option < 6) ? (option + 1) : option;
      // option++;
    } break;
    case char(0xDA): {
      option = (option > 0 ) ? (option - 1) : option;
    } break;
    case char(0xB0): // on enter
    {
      if (lastkey != pressed) {
      switch (option) {
      case 3:
        calibration();
        break;
      case 4:
        option = 9;
        break;
      default:
        break;
      }
      }
    }
    default:
      // nothing
      break;
    }
    lastkey = pressed;
  }
}

void calibration()
{
  char thiskey = 'o';
  delay(200);
  int increment = 1;
  while (thiskey != char(0xB0)) { 
  u8g2.firstPage();
  do {
    drawBorders();
    boxA(cal,0);
    //boxB(cumulative);
    //boxC(MENU_ITEMS, option);
  } while (u8g2.nextPage());
  thiskey = get_button_pressed();
  if (thiskey == char(0xDA)) // up
  {
    increment = 1;
  } else if (thiskey == char(0xD9)) // down
  {
    increment = -1;
  } else {
    hold = 0;
    increment = 0;
  }
  if (lastkey == thiskey) {
    hold++;
    if (hold > 5) {
      increment = increment + increment;
    }
  }
  else {
    hold = 0;
  }
  lastkey = thiskey;
  cal = cal + increment;
  delay(300);
  }
  set_stored_cal(cal);
}

void loop(void)
{
  char thiskey = get_button_pressed();
  if ((lastkey == thiskey) && (thiskey == char(176))) { // KEY_RETURN
    hold++;
    if (hold = 10) {
      menu();
    }
  } 
  else if (thiskey == char(0xDA)) // up
  {
    cum_rotations = 0;
  } else if (thiskey == char(0xD9)) // down
  {
    int_rotations = 0;
  } else {
    hold = 0;
  }
  lastkey = thiskey;
  update_dist();
  u8g2.firstPage();
  do {
    drawBorders();
    boxA(cumulative,cum_places);
    boxB(intermediate,int_places);
  } while (u8g2.nextPage());
  cum_rotations++;
  int_rotations++;
}