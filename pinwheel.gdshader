shader_type canvas_item;
#include "res://complexvisual.gdshaderinc"

const float sqrt5 = sqrt(5.);
const float atan_5 = atan(.5);
const float logsqrt5 = log(sqrt5);
//const vec2 xv_opow = vec2(logsqrt5, - atan_5);
//const vec2 min_exp_xv_opow = (vec2(1.,0.) - cx_exp( xv_opow  ));
const float abs_rem = log( length(vec2(.5)) ) / logsqrt5;

// f(x) = (1 - e^(x * (a + b i)) ) / (1 - e^(a + b i) )
//vec2 newc(vec2 nn){
	//vec2 xvc = cx_exp( cx_mul(nn, xv_opow)  );
	//vec2 res_ri = cx_div((vec2(1.,0.) - xvc), min_exp_xv_opow);
	//return res_ri;
//}
//
//vec2 get_x(vec2 pos){
    //return cx_div( cx_log( vec2(1., 0.) - cx_mul(pos, min_exp_xv_opow) ) , xv_opow);
//}
//x' = x cos θ − y sin θ'
//y' = x sin θ + y cos θ'
vec2 rotate(vec2 vec, float ang){
	vec2 angc = vec2(cos(ang), sin(ang));
	return vec2(vec.x * angc.x - vec.y * angc.y,
				vec.x * angc.y + vec.y * angc.x );
}

bool dot_(vec2 p1, vec2 p2, vec2 pp){
	return  ((p2.x - p1.x) * (pp.y - p1.y) - (p2.y - p1.y) * (pp.x - p1.x)) >= 0.;
}

vec3 to_baryc(vec2 pa, vec2 pb, vec2 pc, vec2 p_){
	//float divs = (pb.y - pc.y)*(pa.x - pc.x) + (pc.x - pb.x)*(pa.y - pc.y);
	//float alp1 = ((pb.y - pc.y)*p_m_y3.x + (pc.x - pb.x)*p_m_y3.y ) / divs;
	//float alp2 = ((pc.y - pa.y)*p_m_y3.x + (pa.x - pc.x)*p_m_y3.y ) / divs;
	vec2 p_m_y3 = p_ - pc;
	vec4 phh = vec4((pb.y - pc.y), (pa.x - pc.x), (pc.x - pb.x), (pa.y - pc.y) );
	float divs = phh.x*phh.y + phh.z*phh.w;

	vec3 bary;
	bary.x = (  phh.x *p_m_y3.x + phh.z*p_m_y3.y ) / divs;
	bary.y = ((-phh.w)*p_m_y3.x + phh.y*p_m_y3.y ) / divs;
	bary.z = 1. - bary.x - bary.y;
	return bary;
}

const vec3 tri_subp[] = {
	vec3(1., 0., 0.),
	vec3(0., 1., 0.),
	vec3(0., 0., 1.),

	vec3(.5, .0, .5), //AL
	vec3(.0, .8, .2), //BL
	vec3(.0, .4, .6), //CL
	vec3(.5, .4, .1)  //LL
};
const ivec2 tri_s_ch[] = {
	ivec2(4, 3), //AL-BL
	ivec2(3, 5), //AL-CL
	ivec2(3, 6), //AL-LL
	ivec2(4, 0)  //A -BL
};
const ivec3 tri_t[] = {
	ivec3(5, 3, 4), // C
	ivec3(5, 3, 2), // D
	ivec3(6, 0, 3), // B
	ivec3(6, 4, 3), // A
	ivec3(4, 1, 0)  // E
};
int tri_subdiv(vec2 ppbary){
	int ch0 = int(dot_(tri_subp[ tri_s_ch[0].x ].xy,tri_subp[ tri_s_ch[0].y ].xy, ppbary.xy)) ;
	int ch1 = int(dot_(tri_subp[ tri_s_ch[1+ch0].x ].xy,tri_subp[ tri_s_ch[1+ch0].y ].xy, ppbary.xy)) ;
	int ch2 = int(dot_(tri_subp[ tri_s_ch[3].x ].xy,tri_subp[ tri_s_ch[3].y ].xy, ppbary.xy)) ;

	//int chout = bool(ch2) ? 4 : ch0 << 1 | ch1;
	int chout = ch2 * 4 | (1-ch2) * (ch0 << 1 | ch1);
	return (chout);
}

const vec3 cl_[] = {
	vec3(.9,.05,.05),
	vec3(.5,.5,.9),
	vec3(.05,.9,.05),
	vec3(.8,.4,.1),

	vec3(.8,.05,.8),
	vec3(.4,.0,.0),
	vec3(.0),
	vec3(.8,.05,.2),

	vec3(.5,.5,.5),
	vec3(.6,.2 ,.9),
	vec3(.1,.2 ,.9),
	vec3(.0),

	vec3(.4,.1,.4),
	vec3(.0),
	vec3(.05,.7,.4),
	vec3(.6,.05,.9),

	vec3(.9,.3,.5)
};
const vec2 poi[] = {
	vec2( 2., -1.),
	vec2( 1.,  0.),
	vec2(-1., -2.),
	vec2( 1.,  2.),
	vec2( 0.,  1.),

	vec2( -2., 1.),
	vec2( -1., 0.),
	vec2( -2., -1.),
	vec2( -3., -2.),
	vec2(-1.8, 2.4),

	vec2(-1.6, 3.8),
	vec2( 2.4, 1.8),
	vec2( 3.8, 1.6),
	vec2( 1.8, -2.4),
	vec2( 1.6, -3.8),

	vec2( -4., -3.),
	vec2( -4., -1.)
};

// x - 90d,   y - len1,   z - len2
const ivec3 tri_p[] = {
	ivec3(9, 5,  3),
	ivec3(9, 10,  3),
	ivec3(6, 5,  3),
	ivec3(6, 5, 8),

	ivec3(16, 8, 5),
	ivec3( 4,  3, 0),
	ivec3(0),
	ivec3(11,  3, 0),

	ivec3(11, 12, 0),
	ivec3(13,14, 2),
	ivec3(13, 0, 2),
	ivec3(0),

	ivec3( 1, 0, 2),
	ivec3(0),
	ivec3( 1, 4, 2),
	ivec3(7, 2,15),
	ivec3(7, 2, 4)
};

const ivec2 t_o0 = ivec2(3, 7);  //_???
const ivec2 t_o1[] = {
	ivec2(3, 5),  //0_??
	ivec2(0, 4)   //1_??
};  //_???
const ivec2 t_o2[] = {
	ivec2(9, 3),
	ivec2(6, 5),
	ivec2(3, 0),
	ivec2(2, 1)
};
const ivec2 t_o3[] = {
	ivec2(9, 3),
	ivec2(9, 3),
	ivec2(6, 5),
	ivec2(8, 5),
	ivec2(3,  0),
	ivec2(11, 0),
	ivec2(2,  0),
	ivec2(2,  4)
};
const ivec2 t_o4[] = {
	ivec2(2, 13),
	ivec2(7,2)
};


uniform float zoom = 1.;
uniform int lod = 6;
uniform sampler2D text;

varying vec2 vertx;
void vertex() {
	vertx = VERTEX;
}

void fragment() {
	vec2 vert_ = vertx * zoom;

	//for(float ii=-2.0; ii < 6.; ii++){
		//vec2 nvec = newc( rotate(vec2(ii , 0.),PI*0.) ) ;
		//COLOR.rgb = mix(COLOR.rgb, vec3(0.), 1.-step(.035, distance(nvec, vert_)) );
	//}

	vec2 coor = vec2( (log(length(vert_ ) )/logsqrt5) - abs_rem , atan(vert_.y, vert_.x) );

	ivec2 coorx = ivec2(int(floor(coor.x)));
	coorx = ivec2( max(coorx.x+abs(lod), abs(lod)), min(coorx.y-lod, -lod) );

	float coor_wh_r = atan_5 * (float(coorx.x)) - PI*.25;
	float line_len = (1./length(vert_))*.01;
	vec2 coord = rotate(vec2(pow(sqrt5, float(coorx.y - abs(lod)) + fract(coor.x)), 0.), coor.y+coor_wh_r);

	int chpos = 0;
	int ch0 = int(dot_(poi[t_o0.x], poi[t_o0.y], coord));
	chpos = ch0;
	int ch1 = int(dot_(poi[t_o1[chpos].x], poi[t_o1[chpos].y], coord));
	chpos = ch0<<1 | ch1;
	int ch2 = int(dot_(poi[t_o2[chpos].x], poi[t_o2[chpos].y], coord));  // 2,6  10,14
	chpos = ch0<<2 | ch1<<1 |  ch2;
	int ch3 = int(dot_(poi[t_o3[chpos].x], poi[t_o3[chpos].y], coord));
	int ch4 = int(dot_(poi[t_o4[ch2].x], poi[t_o4[ch2].y], coord));

	//chpos =  bool(ch0) ? 5 + (!bool(ch1)?(ch2<<1|ch3):4+(ch2<<2|ch3<<1|ch4)) : ((ch1 << 1 | ch2) + (ch1&ch2&ch3));
	chpos =  ch0*5 + ch0*(ch1*4 + ((ch2<<1|ch3)<<ch1) | ch4*ch1) | (1-ch0)*((ch1 << 1 | ch2) + (ch1&ch2&ch3));


	int tri_r=0;
	vec3 bary;
	vec2 bary_c[4];
	bary_c[0] = poi[tri_p[chpos].x];
	bary_c[1] = poi[tri_p[chpos].y];
	bary_c[2] = poi[tri_p[chpos].z];
	bary_c[3] = coord;
	for(int ii=-1;ii < coorx.x; ++ii){
	//for(int ii=-1;ii < 0; ++ii){
		bary = to_baryc(bary_c[0],bary_c[1],bary_c[2], bary_c[3]);
		tri_r = tri_subdiv(bary.xy);
		bary_c[0] = tri_subp[tri_t[tri_r].x].xy;
		bary_c[1] = tri_subp[tri_t[tri_r].y].xy;
		bary_c[2] = tri_subp[tri_t[tri_r].z].xy;
		bary_c[3] = bary.xy;
	}
	bary = to_baryc(bary_c[0],bary_c[1],bary_c[2], bary_c[3]);

	COLOR.rgb = vec3(0.);
	COLOR.rgb = mix(COLOR.rgb, cl_[tri_r] , .7 );

	vec2 texcoor[] = {
		vec2(   bary.z,    bary.y*.5), // C
		vec2(1.-bary.z, .5-bary.y*.5), // D
		vec2(   bary.z, .5+bary.y*.5), // B
		vec2(1.-bary.z, .5-bary.y*.5), // A
		vec2(1.-bary.z, 1.-bary.y*.5)  // E
	};

	//COLOR.rgba = tex1+tex2+tex3+tex4+tex5+tex6+tex7+tex8;
	//COLOR.rgba = texture(text, texcoor[tri_r]);

	COLOR.rgb = mix(COLOR.rgb, vec3(0.) , 1.-step(.01, min(bary.x, min(bary.y, bary.z))) );
	//COLOR.rgb = mix(COLOR.rgb, vec3(0.5), 1.-step(line_len*6., fract(coor.x)  ) );
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
