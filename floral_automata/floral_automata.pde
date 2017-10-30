
import controlP5.*;

/* GUI Controller */
ControlP5 cp5;

/* PGraphics "mini canvas" on which we draw the mandalas */
PGraphics mini_canvas;

/* 
	Parameters section
	N: 		The size of the cellular automaton's memory
	K: 		The size of the neighborhood (K-connected)
	S: 		The number of symbols
	MAX_IT: The iteration depth
*/
int N;
int K;
int S;
int MAX_IT;
int BLUR_LEVEL;
int THRESHOLDING_LEVEL;
boolean descending;
ScrollableList mode;
boolean hsb;

/* 
	tape: 		A N-sized array representing the cellular automaton's memory
	transition:	A S^K array mapping each K-connected neighborhood to a symbol 0 <= s < S
	kernel: 	A K-sized array which when convolved with the tape yields the appropriate indices of the transition array
*/
int[] tape;
int[] transition;
int[] kernel;

/* code: The Wolfram encoding of the current rule */
int code;

/* t: Time variable */
int t;

void setup()
{
	size(500,500);

	init_tape();
	init_kernel();
	init_transition();

	mini_canvas = createGraphics(500,500);
	mini_canvas.beginDraw();
	mini_canvas.background(0);
	mini_canvas.endDraw();
	init_GUI();
	hsb = false;

	t = 0;
}

void draw()
{
	background(255);

	switch((int)mode.getValue())
	{
		case 1: descending = false; break;
		case 2: descending = true; break;
		default: break;
	}

	draw_flower();

	t += 1;
	if(t >= MAX_IT)
	{
		t -= MAX_IT;

		init_tape();
		//decode((code+=1)%(int(pow(S,pow(S,K)))));
		random_rule();
		
		if((int)mode.getValue() == 0)
		{
			descending = !descending;
		}
	}
}

void draw_flower()
{
	boolean one_pass = (int)mode.getValue()==3;
	
	if(one_pass)
		init_tape();

	mini_canvas.beginDraw();

	if(one_pass) mini_canvas.background(0);

	for(int i = (one_pass ? 0 : t); i <= (one_pass ? MAX_IT : t); i++)
	{
		float r0 = 0.4*height*float(MAX_IT-(descending?i:(MAX_IT-i))-(descending?0:1))/MAX_IT;
		float r1 = 0.4*height*float(MAX_IT-(descending?i:(MAX_IT-i))-(descending?1:0))/MAX_IT;
		for(int j = 0; j < N; j++)
		{
			float a0 = TWO_PI*(j-1+0.5)/N;
			float a1 = TWO_PI*(j+0.5)/N;

			if(hsb)
			{
				mini_canvas.stroke 	(255*(S-1-tape[j])/(S),200,200);
				mini_canvas.fill 	(255*(S-1-tape[j])/(S),200,200);
			}
			else
			{
				mini_canvas.stroke 	(255*(S-1-tape[j])/(S-1));
				mini_canvas.fill 	(255*(S-1-tape[j])/(S-1));
			}
			
			mini_canvas.beginShape();
				mini_canvas.vertex(width/2+r0*cos(a0),height/2+r0*sin(a0));
				mini_canvas.vertex(width/2+r0*cos(a1),height/2+r0*sin(a1));
				mini_canvas.vertex(width/2+r1*cos(a1),height/2+r1*sin(a1));
				mini_canvas.vertex(width/2+r1*cos(a0),height/2+r1*sin(a0));
			mini_canvas.endShape();
		}

		update_tape();
	}

	if(BLUR_LEVEL > 0)								mini_canvas.filter(BLUR,BLUR_LEVEL);
	if(BLUR_LEVEL > 0 || THRESHOLDING_LEVEL < S)	mini_canvas.filter(POSTERIZE,THRESHOLDING_LEVEL);

	mini_canvas.endDraw();

	image(mini_canvas,(width-mini_canvas.width)/2,(height-mini_canvas.height)/2);
}

void init_tape()
{
	tape = new int[N];
	for(int i = 0; i < N; i++)
		tape[i] = i%(N/8) == 0 ? 1 : 0;
}

void init_kernel()
{
	kernel = new int[K];
	for(int i = 0; i < K; i++)
		kernel[i] = int(pow(2,i));
}

void init_transition()
{
	transition = new int[int(pow(S,K))];
	decode(int(random(0,pow(S,K))));
}

void random_rule()
{
	for(int i = 0; i < int(pow(S,K)); i++)
		transition[i] = int(random(0,S));
}

void decode(int code)
{
	int i = transition.length-1;
	while(code > 0)
	{
		transition[i--] = code%S;
		code /= S;
	}
}

int[] convolution(int[] x, int[] kernel)
{
	int[] y = new int[x.length];
	for(int i = 0; i < x.length; i++)
		for(int j = 0; j < kernel.length; j++)
			y[i] += x[(i-kernel.length/2+j+x.length)%(x.length)]*kernel[kernel.length-j-1];
	return y;
}

/*
	You may have not realized, but the updating of a cellular automaton grid
	can be concisely implemented by the composition of a convolution and a
	function f : S^K -> S.

	By convolving the tape with a kernel composed of powers of S [S^K, S^(K-1), ... , S^1, S^0],
	we map each tape position to a unique integer 0 <= i < S^K which encodes its neighborhood.
	We can then proceed to map the transition function to the result, and voilà: we have updated
	the tape according to the cellular automata's ruleset.
*/
void update_tape()
{
	tape = convolution(tape,kernel);
	for(int i = 0; i < N; i++)
		tape[i] = transition[tape[i]];
}

void keyPressed()
{
	if(cp5.isVisible())
		cp5.hide();
	else
		cp5.show();
}

void init_GUI()
{
	cp5 = new ControlP5(this);

	int i = 0;

	cp5.addSlider("Tape_Size")
	.setValue(12)
	.setRange(2,20)
	.setPosition(0,21*(i++))
	.setSize(120,20)
	.setColorLabel((int)color(255,0,0))
	;

	cp5.addSlider("Neighborhood_Size")
	.setValue(3)
	.setRange(1,20)
	.setPosition(0,21*(i++))
	.setSize(120,20)
	.setColorLabel((int)color(255,0,0))
	;

	cp5.addSlider("Symbols")
	.setValue(2)
	.setRange(2,10)
	.setPosition(0,21*(i++))
	.setSize(120,20)
	.setColorLabel((int)color(255,0,0))
	;

	cp5.addSlider("Iteration_Depth")
	.setValue(20)
	.setRange(2,100)
	.setPosition(0,21*(i++))
	.setSize(120,20)
	.setColorLabel((int)color(255,0,0))
	;

	cp5.addSlider("Blur_Level")
	.setValue(2)
	.setRange(0,10)
	.setPosition(0,21*(i++))
	.setSize(120,20)
	.setColorLabel((int)color(255,0,0))
	;

	cp5.addSlider("Thresholding_Level")
	.setValue(3)
	.setRange(2,10)
	.setPosition(0,21*(i++))
	.setSize(120,20)
	.setColorLabel((int)color(255,0,0))
	;

	cp5.addButton("Hue_Scale")
	.setValue(0)
	.setPosition(0,21*(i++))
	.setSize(120,20)
	;

	mode = cp5.addScrollableList("Drawing_Mode")
	.setPosition(0,21*(i++))
	.setSize(120,70)
	;

	mode.addItem("Alternating",	new Object());
	mode.addItem("Ascending",	new Object());
	mode.addItem("Descending",	new Object());
	mode.addItem("One_Pass",	new Object());
}

void Tape_Size(int x)
{
	N = 8*x;
	code = 0;
	init_tape();
}

void Neighborhood_Size(int x)
{
	K = x;
	code = 0;
	init_kernel();
	init_transition();
}

void Symbols(int x)
{
	S = x;
	code = 0;
	init_transition();
}

void Iteration_Depth(int x)
{

	MAX_IT = x;
}

void Blur_Level(int x)
{

	BLUR_LEVEL = x;
}

void Thresholding_Level(int x)
{

	THRESHOLDING_LEVEL = x;
}

void Hue_Scale()
{
	hsb = !hsb;
	if(hsb)
		mini_canvas.colorMode(HSB);
	else
		mini_canvas.colorMode(RGB);
}