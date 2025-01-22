/* @pjs preload="urns/0.png"; */
/* @pjs preload="urns/1.png"; */
/* @pjs preload="urns/2.png"; */
/* @pjs preload="urns/3.png"; */

ArrayList urns;					// urn array
ArrayList shatter;				// shattered urn array
PImage[] u = new PImage[4];		// urn IMAGE array

int fontsize = 24;				// font size
long damage = 0;				// property damage

bgcolor = color(126,63,199);	// sketch background color

float acceleration = 9;			// urn downward acceleration

mobileWidth = 700;

float textY = 0;  // text Y (for mobile)


// sound shit
Audio[] audio = new Audio();	//make a new HTML5 audio object named audio
String fileExt;				// make string that will house the audio extension

// variables to hold the current vase details
int currX = 0;
int currY = 0;
float currA = 0;	// angle
int currU = 0;		// current urn image
color currC1 = color(0,0,0);	// color (for shatter)
color currC2 = color(255,0,0);	// color (for shatter)

// shatter stuff
ArrayList<UrnExplode> lists = new ArrayList<UrnExplode>();
float x;
float y;
float yspeed = 0;
float chipSize = 14;
float velo = 0;
float gravity =.2;
int bitCount = 30;		// number of little bits to explode

void setup() {
  doResize();					// make sketch size equal to doc size
  urns = new ArrayList(); 	// create an empty urn ArrayList
  shatter = new ArrayList(); 	// create an empty urn ArrayList

  // set up urns
  if(width < mobileWidth) {
    u[0] = loadImage("urns/s0.png");  // small ones (mobile)
    u[1] = loadImage("urns/s1.png");
    u[2] = loadImage("urns/s2.png");
    u[3] = loadImage("urns/s3.png");
    bitCount = 20;
    chipSize = 9;
    textSize(12);
    textY = 10;
  } else {
    u[0] = loadImage("urns/0.png");   // big ones (heh heh)
    u[1] = loadImage("urns/1.png");
    u[2] = loadImage("urns/2.png");
    u[3] = loadImage("urns/3.png");  
    textSize(22);  
    textY = height/10;
  }
  

	// create starting urn rotation
	currA = random(TWO_PI);	// random starting angle

  imageMode(CENTER);
  rectMode(CENTER);
  noStroke();
  noCursor();


  // detect which extension we ought to use
  if (audio.canPlayType && audio.canPlayType("audio/ogg")) {
  	fileExt = ".ogg";
  } else {
  	fileExt = ".mp3";
  }
  //loads the audio file and appends the file extension
  audio.setAttribute("src","break"+fileExt);
}

void draw() {

	background(bgcolor);

	// draw current urn ... if not mobile!
  if(width > mobileWidth) {
  	pushMatrix();
  		translate(mouseX, mouseY);
  		rotate(currA);
  		image(u[currU], 0, 0);
  	popMatrix();
  }
	// iterate thru urns
	for (int i = urns.size()-1; i >= 0; i--) { 
		Urn urn = (Urn) urns.get(i);	// grab i urn
		urn.update();					// update dat shit
		urn.checkSmash(i);
	}

	// iterate thru shattering urns
	arrayBreak();

  // draw text
  String damages = "approximate property damage: $" + nf(damage,1,2);
	float twidth = textWidth(damages);
	fill(255);	// white text
	text(damages, (width-twidth)/2, textY);
}

function doResize() {
	var setupHeight = Math.max($(document).height(), $(window).height());
	$('#sketch').width($(window).width());
	$('#sketch').height(setupHeight);
	size($(window).width(), setupHeight);
}
$(window).resize(doResize);

void mousePressed() {
  // A new urn object is added to the ArrayList, by default to the end
  urns.add(new Urn(mouseX, mouseY, currA, u[currU]));
  checkColor();
  // make new "current" urn
  currA = random(TWO_PI);	// random starting angle
  currU = int(random(4));	// random urn image (make sure to set corresponding color)
}

// animate smashing
void arrayBreak() {
  for (int i = 0; i < lists.size(); i++) {

    UrnExplode aUrn = lists.get(i);
    aUrn.move();
    if (aUrn.x >= width|| aUrn.y <= 0 || aUrn.x <=0|| aUrn.y >= height ) {  
    	lists.remove(aUrn);
    }
    if (aUrn.age > 1000) {	// REMOVE OLD PIECES
    	lists.remove(aUrn);
    }
  }
}

void checkColor() {
  // grab correct colors from urn at hand
  switch(currU) {
  	case 0:
  		currC1 = color(5,141,141);
  		currC2 = color(255,183, 158);
  		break;
  	case 1:
  		currC1 = color(207,25,38);
  		currC2 = color(196,214,102);
  		break;
  	case 2:
  		currC1 = color(70,39,98);
  		currC2 = color(177,217,208);
  		break;
  	case 3:
  		currC1 = color(150,11,12);
  		currC2 = color(255,198,0);
  		break;
  }
}

class Urn { 

  int x, y, acc;
  float angle;
  PImage img;

  Urn (int _x, int _y, float _angle, PImage _img) {  
    x = _x;
    y = _y;
    angle = _angle;
    img = _img;
    acc = acceleration;
  } 

  void update() {

  	pushMatrix();
  		translate(x,y);
  		rotate(angle);
    	image(img, 0, 0);
    popMatrix();

    y += acc;
  }

  void checkSmash(int index) {		
  	    if( y > height - 15) {
    	acc = 0;	// stop acceleration
    	img = 0;

    	urns.remove(index);
    	
    	for (int i=0;i<bitCount;i++) { 

    		// randomize between two urn colors
    		if(random(0,1) > .5) {
    			lists.add(new UrnExplode(x, y, currC1));
    		} else {
				lists.add(new UrnExplode(x, y, currC2));
    		}
  		}
  		//audio.stop();
		audio.play();	//play the audio
		damage += random(900000,1100000);	// increase damage
    }
  }
}

class UrnExplode {
  float x;
  float y;
  float squareWidth;
  float xSmallSquare = x;
  boolean ySpeedFirst = true;
  float yspeed = 0;
  float xChange;
  float rot;
  color col;

  int age = 0;	// remove them after a while

  void move() {  
    x += xChange;
    y += yspeed; 

    if(y < height - 10) {	// CHECK FOR SMASHY
    	yspeed = yspeed += 0.2;
    	rot+=.1;
	} else {
		yspeed = 0;
		xChange = xChange / 2;
	}

    fill(col);  // fill w color of vase
    pushMatrix();
    translate(x,y);
    rotate(rot);
    rect(0,0, squareWidth, squareWidth);
    popMatrix();

    age ++;
  }
  
  UrnExplode(float x, float y, color c) {
    xChange = (random(0, 20))-10;
    yspeed = (random(-10, 0));
    this.x = x;
    this.y = y;
    squareWidth = chipSize;
    rot = random(0, TWO_PI);

    col = c;	// urn color

  }
}