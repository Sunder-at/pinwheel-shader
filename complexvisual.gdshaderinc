

float cosine_lerp(float y1,float y2, float mu) {
   float mu2 = (1.0-cos(mu*PI))* 0.5;
   return(y1*(1.0-mu2)+y2*mu2);
}

/**
 *
 * Complex math functions
 *
        ((a.x*a.x)+(a.y*a.y))
 */


#define cx_add(a, b) vec2(a.x + b.x, a.y + b.y)
#define cx_sub(a, b) vec2(a.x - b.x, a.y - b.y)
#define cx_mul(a, b) vec2(a.x*b.x-a.y*b.y, a.x*b.y+a.y*b.x)
#define cx_div(a, b) vec2(((a.x*b.x+a.y*b.y)/(b.x*b.x+b.y*b.y)),((a.y*b.x-a.x*b.y)/(b.x*b.x+b.y*b.y)))
#define cx_modulus(a) length(a)
#define cx_conj(a) vec2(a.x,-a.y)
#define cx_arg(a) atan(a.y,a.x)
#define cx_sin(a) vec2(sin(a.x) * cosh(a.y), cos(a.x) * sinh(a.y))
#define cx_cos(a) vec2(cos(a.x) * cosh(a.y), -sin(a.x) * sinh(a.y))

vec2 cx_to_polar(vec2 a) {
    float phi = atan(a.x, a.y);
    float r = sqrt(a.x * a.x + a.y * a.y);
    return vec2(r, phi);
}

vec2 cx_sqrt(vec2 a) {
    float r = sqrt(a.x*a.x+a.y*a.y);
    float rpart = sqrt(0.5*(r+a.x));
    float ipart = sqrt(0.5*(r-a.x));
    if (a.y < 0.0) ipart = -ipart;
    return vec2(rpart,ipart);
}

vec2 cx_tan(vec2 a) {return cx_div(cx_sin(a), cx_cos(a)); }

//vec2 cx_log(vec2 a) {
    //float rpart = sqrt((a.x*a.x)+(a.y*a.y));
    //float ipart = atan(a.y,a.x);
    //if (ipart > PI) ipart=ipart-(2.0*PI);
    //return vec2(log(rpart),ipart);
//}

//vec2 cx_exp(vec2 z){
    //vec2 w = vec2( cos(z.y), sin(z.y));
    //w *= exp(z.x);
    //return w;
//}
#define cx_exp(z) vec2( cos(z.y), sin(z.y)) * exp(z.x)


float cx_mag(in vec2 z) {
    return sqrt(dot(z,z));
}

vec2 cx_log(vec2 z){
    return vec2( log(cx_mag(z)), cx_arg(z));
}

vec2 cx_mobius(vec2 a) {
    vec2 c1 = a - vec2(1.0,0.0);
    vec2 c2 = a + vec2(1.0,0.0);
    return cx_div(c1, c2);
}

//vec2 jitter(vec2 c) { return c + noise2(c) * JitterRadius; }
// END Complex math functions

float rand(vec2 co){ return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);}

//vec2 jitter(vec2 c) {
    //float xoff = ((rand(vec2(c.x,c.y))*2.0) -1.0) * JitterRadius; // * Zoom;
    //float yoff = ((rand(vec2(c.y,c.x))*2.0) -1.0) * JitterRadius; // * Zoom;
    ////vec2 n = noise2(ctmp);
    //return (c + vec2(xoff,yoff));
//}



//
// Noise
vec4 rand2(vec2 A,vec2 B,vec2 C,vec2 D){
    vec2 s=vec2(12.9898,78.233);
    vec4 tmp=vec4(dot(A,s),dot(B,s),dot(C,s),dot(D,s));
    return fract(sin(tmp) * 43758.5453)* 2.0 - 1.0;
}

float noise(vec2 coord,float d){
    vec2 C[4];
    float d1 = 1.0/d;
    C[0]=floor(coord*d)*d1;
    C[1]=C[0]+vec2(d1,0.0);
    C[2]=C[0]+vec2(d1,d1);
    C[3]=C[0]+vec2(0.0,d1);
    vec2 p=fract(coord*d);
    vec2 q=1.0-p;
    vec4 w=vec4(q.x*q.y,p.x*q.y,p.x*p.y,q.x*p.y);
    return dot(vec4(rand2(C[0],C[1],C[2],C[3])),w);
}

//vec4 get_noise_color(vec2 a) {
    //float level= -log2(min(length(dFdx(a)),length(dFdy(a))));
    //level = min(level,13.0); //limit the level to avoid slowness
    //float n = 0.5;
    //for(int i = 3; i< int(level);i++){ //3 is the lowest noise level
        //n +=  0.12 * noise(a, exp2(float(i)));
    //}
    //return vec4(n,n,n,n);
//}


// End Noise
//


float get_smooth_branch_factor(float u, float v) {
    float fmult = 2.0; // frequency multiplyer
    u = clamp(u,0.0,1.0);
    v = clamp(v,0.0,1.0);
    float a = 0.5 + (0.5 * -cos(u*fmult * (2.0*PI)));
    float b = 0.5 + (0.5 * -cos((u*2.0*fmult)*(2.0*PI)));
    return (a+((b-a)*v)); // lerp (a,b,v)
  }

//vec4 mandelbrot(vec2 z) {
    //float   real  = z.x; // gl_TexCoord[0].s * Zoom + Position.x;
    //float   imag  = z.y; //gl_TexCoord[0].t * Zoom + Position.y;
    //float   Creal = real;   // Change this line...
    //float   Cimag = imag;   // ...and this one to get a Julia set
//
    //float r2 = 0.0;
    //float iter;
//
    //for (iter = 0.0; iter < MaxIterations && r2 < 16.0; ++iter) {
        //float tempreal = real;
        //real = (tempreal * tempreal) - (imag * imag) + Creal;
        //imag = 2.0 * tempreal * imag + Cimag;
        //r2   = (real * real) + (imag * imag);
    //}
//
    //if(r2 < 16.0) {
        //return vec4(0.0,0.0,0.0,1.0);
    //}
//
//
    //float modulus = sqrt(r2); //sqrt (ReZ*ReZ + ImZ*ImZ);
    //float mu = iter - (log (log (modulus)))/ log (2.0);
//
    //mu += 0.5;
    //float lo_boundary=0.0;
    //float nearest_boundary = round(mu);
    //if (nearest_boundary < mu) {
        //lo_boundary = nearest_boundary;
    //}
    //else {
        //lo_boundary = nearest_boundary - 1.0;
    //}
    //mu -= lo_boundary;
//
    //float arg = atan(imag,real);
    //arg = ((arg + PI) / (2.0* PI));
//
//
    //// smooth branch shading
    //float sbf = get_smooth_branch_factor(arg, mu);
    //return vec4(sbf,sbf,sbf,sbf);
//
    //// Base the color on the number of iterations
///*
    //vec3 color;
    //if (r2 < 4.0)
        //color = InnerColor;
    //else
        //color = mix(OuterColor1, OuterColor2, fract(iter * 0.05));
//
    //return vec4 (clamp(color, 0.0, 1.0), 1.0);
//*/
//}
//
//
