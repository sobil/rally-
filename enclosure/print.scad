// RALLY- Enclosure
edge_radius = 4;
depth = 12; d = depth;
width = 135; w = width;
height = 2.8*4+2+2+54.5; h = height;
wall_thickness = 2;
button_hole_diameter=12;
circle_resolution=10;
screen_offset_percentage=0.22;
screw_size=3;
so = [71,39]; screen_opening = so;
s = [86.5,54.5,wall_thickness]; screen = s;
b= [97,54,2]; board=b;






mirror([0,1,0]) board_retainer(screw_size);


difference() {
//    box(d, w, h, edge_radius, wall_thickness);
//    hull() translate([w*screen_offset_percentage,wall_thickness,0]) screen_mount(wall_thickness,s);
}
//translate([w*screen_offset_percentage,s[1]+wall_thickness+4*screw_size,0]) mirror([0,1,0]) screen_mount(wall_thickness,s);


module box(d, w, h, r, wall, top=0) {
    o = 0; origin = o;
    
    difference() {
        //the outer box
        outer();
        // remove the screw post before adding it back in (so the screw holes dont get blocked up
        translate([o, o, wall])screw_holes(post_diameter=r*2,screw_diameter = 0);
        //make hollow
        translate([wall, wall, wall]) scale([((w - 2 * wall) / w),((h - 2 * wall) / h),1]) outer();
        //add step
        translate([wall/2, wall/2, d-wall]) scale([((w - wall) / w),((h - wall) / h),1]) outer();
        //button holes
    button_spread=0.65;
    translate([(1-button_spread)/2.5*w,(1-button_spread)*h*.5,0]) rotate([0,0, 0]) holes(button_hole_diameter, 3, h*button_spread);
        
    }
    screw_holes(post_diameter=r*2, screw_diameter= 2.8,length=d-wall);

    module outer() {
       hull() screw_holes(post_diameter=r*2,length=d);
    }
    module inner() {
        x_scale = (w - 2 * wall) / w;
        y_scale = (h - 2 * wall) / h;
        scale([x_scale, y_scale, 1]) outer();
    }

    module screw_holes(post_diameter, screw_diameter, length) {
        od = post_diameter;
        r = post_diameter/2;
        translate([r, r, o]) tube(od, screw_diameter, length);
        translate([w - r, h - r, o]) tube(od, screw_diameter, length);
        translate([w - r, o + r, o]) tube(od, screw_diameter, length);
        translate([o + r, h - r, o]) tube(od, screw_diameter, length);
    }

    module holes(diameter, number = 1, spread = 0) {
        if (spread > 0) {
            spacing = spread / (number-1);
            translate([o, o, o]) for (i = [0: number-1]) {
                translate([0, i * spacing, 0]) cylinder(wall, d = diameter, $fn=circle_resolution);
            }
        }
        else {
            spacing = (diameter * 1.5);
            translate([diameter/2, diameter/2, o]) for (i = [0: number - 1]) {
                translate([0, i * spacing, 0]) cylinder(wall, d = diameter, $fn=circle_resolution);
            }
        }
    }

};






module screen_mount(wall,screen) {  
  so_vertical_offset = 12;
  lr = [s[0]+wall*2,s[1]+(wall*2),2*wall];locating_ring =lr;
  screen_thickness=5;
  clearance=3;

  difference() {
    union() {
        cube([s[0]+2*wall,s[1]+4*screw_size,wall]);
        difference(){
            translate([0,2*screw_size-wall,0]) cube(lr);
            //space for the little bump on the screen
            translate([wall/2,2*screw_size+so[1]/2-5+so_vertical_offset,0]) cube([lr[0]-wall,10,lr[2]]);
        }
    }
    color("red") translate([(lr[0]-so[0])*.5,2*screw_size-wall+so_vertical_offset+wall,0]) cube([71,39,wall*20]);
    color("blue") translate([(lr[0]-s[0])/2,2*screw_size-wall+(lr[1]-s[1])/2,wall]) cube([s[0],s[1],wall*2]);
    color("green") translate([(lr[0]-s[0])/2,2*screw_size-wall+(lr[1]-s[1])/2,wall]) cube([s[0],s[1],wall*2]);
  }


    screen_screw_blocks(screw_size,wall+screen_thickness+clearance,screen,wall);
    height = wall+screen_thickness+clearance;

};

  module screen_screw_blocks(screw_size,height,screen,wall,block_size=screw_size*2) {
    screw_block(block_size,height,screw_size);
    translate([0,screen[1]+block_size,0]) screw_block(block_size,height,screw_size);
    translate([screen[0]+2*wall-block_size,screen[1]+block_size,0]) screw_block(block_size,height,screw_size);  
    translate([screen[0]+2*wall-block_size,0,0]) screw_block(block_size,height,screw_size);
  }
  

  module screw_block(block_width,depth,hole_size=0) {
    b=block_width;
    difference() {
        cube([b,b,depth]);
        translate([b/2,b/2,]) cylinder(depth,d=hole_size, $fn=circle_resolution);
    }

  }



module tube(od=10, id=5, h) {
    difference() {
        cylinder(h, r = od / 2, $fn = circle_resolution);
        cylinder(h, r = id / 2, $fn = circle_resolution);
    }
}



module board_retainer(screw_size) {
  screw_lug_offset=3;
  difference() {  
    union() {
      translate([0,2*screw_size-wall_thickness,0]) difference() {
        //outer rim  
        cube([b[0]+2*wall_thickness,b[1]+2*wall_thickness,3*wall_thickness]);
        
        translate([wall_thickness,wall_thickness,0]) cube([b[0],b[1],wall_thickness*2]);
        translate([wall_thickness*2,wall_thickness*2,0]) cube([b[0]-2*wall_thickness,b[1]-2*wall_thickness,wall_thickness*3]);
      }
      translate([23.5+wall_thickness,screw_size*2-wall_thickness,wall_thickness*2]) cube([45,15,wall_thickness]);
    }
    //create void for screw lugs
    translate([screw_lug_offset,0,0]) screen_screw_blocks(0,wall_thickness*3,s,wall_thickness,screw_size*2);
    translate([33.5+wall_thickness,screw_size*2-wall_thickness,0]) cube([25,8,wall_thickness*4]);
  translate([23.5+wall_thickness,screw_size*2-wall_thickness,0]) cube([45,15,wall_thickness*2]);
  }
  //create screw lugs
  translate([screw_lug_offset,0,0]) screen_screw_blocks(screw_size+.2,wall_thickness*3,s,wall_thickness,screw_size*2);
}


//translate([0,0,100]) screen_spacer(2,97,54,6,3);
module screen_spacer(height,width,depth, standoff_width, standoff_height) {
    translate([0,0,height]) cube([standoff_width,standoff_width,standoff_height]);
    translate([width-standoff_width,0,height]) cube([standoff_width,standoff_width,standoff_height]);
    translate([width-standoff_width,depth-standoff_width,height]) cube([standoff_width,standoff_width,standoff_height]);
    translate([0,depth-standoff_width,height]) cube([standoff_width,standoff_width,standoff_height]);
    hole_percentage=0.7;
    difference (){
        translate([0,0,0]) cube([width,depth,height]);
        translate([width/2-width*hole_percentage/2,depth/2-depth*hole_percentage/2,0]) cube([width*hole_percentage,depth*hole_percentage,height]);

   }
}
