/*
 * LED Matrix
 *
 */

#include <EEPROM.h>

#define LIVE 0 
#define STANDALONE 1 

#define FRAME_BUFFER_SIZE 512 //BYTES

#define BAUD_RATE 115200

#define CRTL 255
#define RESET 255

#define WRITE_FRAME 253
#define WRITE_EEPROM 252
#define READ_EEPROM 251

#define SPEED 249
#define SPEED_INC 128 //B1000 0000
#define SPEED_DEC 1   //B0000 0001

#define DEFAULT_SPEED 10000

// int numX = 8;
byte numY = 5;
byte numFrames = 0;

unsigned int current_frame_nr = 0;
unsigned int current_frame_offset = 0;
unsigned int current_row = 0;

byte serial[3]; //keep last 3 vlaues read from serial

//running mode
byte mode = STANDALONE;

unsigned int current_delay = 0;
unsigned int current_speed = DEFAULT_SPEED; 

byte frame_buffer[FRAME_BUFFER_SIZE]; //size of EEPROM -> to read faster??

void setup_timer2(){
  TCCR2A = 0;
  TCCR2B = 0<<CS22 | 1<<CS21 | 1<<CS20; 

  //Timer2 Overflow Interrupt Enable   
  TIMSK2 = 1<<TOIE2;
  TCNT2 = 0 ; 
}

//Timer2 overflow interrupt vector handler
ISR(TIMER2_OVF_vect) {
  output_row( current_row, frame_buffer[current_frame_offset + current_row]);    
  current_row = (current_row >= numY - 1) ? 0 : current_row + 1; 
}

void setup() {
  Serial.begin(BAUD_RATE);

  for(int i = 2; i < 13; i++ ) {
    pinMode(i, OUTPUT);      // sets the digital pin as output
    digitalWrite(i, LOW);    
  } 

  load_from_eeprom(0);
  reset();
  setup_timer2();
}

void reset() {
  current_frame_nr = 0;   
  current_row = 0;
  current_frame_offset = current_frame_nr * numY;
  current_delay = 0;
  current_speed = DEFAULT_SPEED;
  mode = STANDALONE;
}

void loop() {
  check_serial();
  next_frame();
}

void next_frame() {
  if( mode == LIVE ) return; 
  if(current_delay < 1) {      
    current_delay = current_speed; // / numY /numY * 300;   
    current_frame_nr++;
    if(current_frame_nr >= numFrames) current_frame_nr = 0;
    current_frame_offset = current_frame_nr * numY;
  }
  current_delay--;
} 

void check_serial() {
  if( !Serial.available() ) return;
  byte value = read_serial();
  if( value == CRTL ) {
    switch( wait_and_read_serial() ) {
    case RESET:
      load_from_eeprom(0);
      reset();
      break;
    case WRITE_EEPROM: 
      write_to_eeprom(0);
      break;
    case WRITE_FRAME:   
      write_to_frame( current_frame_nr );
      mode = LIVE;
      break;
    case SPEED:
      value = wait_and_read_serial();
      if( value == SPEED_INC && current_speed > 100 ) current_speed -= 100;
      if( value == SPEED_DEC ) current_speed += 100;
      break;
    }
  }
}

byte read_serial() {  
  serial[2] = serial[1];
  serial[1] = serial[0];
  serial[0] = Serial.read();
  return serial[0];
}

byte wait_and_read_serial() {
  while( !Serial.available() );
  return read_serial();
}

void output_row( byte row, byte value ) {
  PORTD = (value << 2 )| (PIND & B00000011);
  PORTB = ~( 1 << row );
}

void write_to_frame(unsigned int frame_nr ) {  
  byte value;
  unsigned int frame_offset = frame_nr * numY;
  for( byte row = 0; row < numY; row++ ) {
    value = wait_and_read_serial();
    frame_buffer[frame_offset + row] = value;  
  }
}

void write_to_eeprom( int addr ) {  
  //int slot = wait_and_read_serial(); 
  // byte serialY = wait_and_read_serial(); // numY
  // byte serialSpeed = wait_and_read_serial(); // numY  
  byte new_numFrames = wait_and_read_serial();
  EEPROM.write(addr, new_numFrames);  

  byte new_numY = wait_and_read_serial();
  EEPROM.write(addr + 1, new_numY);  

  byte value;
  for( int row = 0; row< new_numFrames * new_numY; row++ ) {
    value = wait_and_read_serial();
    EEPROM.write(addr + 2 + row, value);      
  }
}

void load_from_eeprom( int addr ) {
  numFrames = EEPROM.read(addr);
  numY      = EEPROM.read(addr + 1); 

  for( unsigned int row = 0; row< numFrames * numY; row++ ) {
    frame_buffer[row] = EEPROM.read(addr + 2 + row);
  }
}

/* 
 digitalWrite(ledPin, LOW);  
 v = wait_and_read_serial();
 if( v == 255 ) digitalWrite(ledPin, HIGH);  
 wait_and_read_serial();
 */
//  delayMicroseconds(100);
/* if( row == 2 ) {
 PORTD = (0 << 2 )| (PIND & B00000011);
 //  delayMicroseconds(500);
 } */



/* 
 for(int i=0; i< FRAME_BUFFER_SIZE; i++) {
 frame_buffer[i] = i; //abs(sin( i ) ) * 64;
 }
 */