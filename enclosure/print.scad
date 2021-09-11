// RALLY- Enclosure
edge_radius = 4;
depth = 12; d = depth;
width = 135; w = width;
height = s[1]+4*screw_size++2*wall_thickness; h = height;
wall_thickness = 2;
button_hole_diameter=12;
circle_resolution=10;
screen_offset_distance=width-s[0]-2*wall_thickness-2*edge_radius-8;
screw_size=3;
so = [71,39]; screen_opening = so;
s = [86.5,54.5,wall_thickness]; screen = s;
b= [97,54,2]; board=b;
back_depth=25;
mount_bolt_spacing=80;

//spacer
//translate([0,0,50]) screen_spacer(2,97,54,6,3);

//Retainer
//translate([0,100,100]) mirror([0,1,0]) board_retainer(screw_size);

//Face
//face();

//Back plate
//translate([0,100,200]) back();

module back() {
  union() {
      difference() {
          box(back_depth-wall_thickness, w, h, edge_radius, wall_thickness,top=0); 
          translate([w/2-mount_bolt_spacing/2,h/2,0]) hull() bolt_boss(head=10,shank=6,wall=wall_thickness);
          translate([w/2+mount_bolt_spacing/2,h/2,0]) hull() bolt_boss(head=10,shank=6,wall=wall_thickness);
      }
      //inner rim (gotta be a better way)
      difference() {
          box(back_depth, w, h, edge_radius, wall_thickness,top=0);
          box(back_depth, w, h, edge_radius, wall_thickness,top=1);
      }
      translate([w/2-mount_bolt_spacing/2,h/2,0]) bolt_boss(head=10,shank=6,wall=wall_thickness);
      translate([w/2+mount_bolt_spacing/2,h/2,0]) bolt_boss(head=10,shank=6,wall=wall_thickness);
   } 
}

module bolt_boss(head, shank, wall) {
    difference() {
      color("red") cylinder(h=3*wall_thickness,d2=head+wall_thickness*2, d1=head+wall_thickness*6, $fn=circle_resolution);
      color("red") translate([0,0,wall*1.5]) cylinder(h=4*wall_thickness,d=head, $fn=6);
      color("red") cylinder(h=4*wall_thickness,d=shank, $fn=circle_resolution);
    }
}

module face() {
    //button holes
    button_spread=0.65;
    difference() {
        box(d, w, h, edge_radius, wall_thickness,top=1);
        hull() translate([screen_offset_distance,s[1]+wall_thickness+4*screw_size,0]) mirror([0,1,0]) screen_mount(wall_thickness,s);
        color ("blue") translate([1.5*button_hole_diameter,(1-button_spread)*h*.5,0]) rotate([0,0, 0]) holes(button_hole_diameter, 3, h*button_spread, wall_thickness);
    }   
    translate([screen_offset_distance,s[1]+wall_thickness+4*screw_size,0]) mirror([0,1,0]) screen_mount(wall_thickness,s);
}

module box(d, w, h, r, wall, top=0) {
    o = 0; origin = o;
    difference() {
        //the outer box
        outer(w,h,d,r);
        //make hollow
        translate([wall, wall, wall]) scale([((w - 2 * wall) / w),((h - 2 * wall) / h),1]) outer(w,h,d,r);
        //add outside step
        if (top==1) translate([wall/2, wall/2, d-wall]) scale([((w - wall) / w),((h - wall) / h),1]) outer(w,h,d,r);
        if (top==1) screw_holes(post_diameter=r*2, screw_diameter=2.8,length=d-wall,x=w-wall,y=h-wall);
        // remove the screw post before adding it back in (so the screw holes dont get blocked up
        if (top==0) translate([wall/2,wall/2,0]) screw_holes(post_diameter=r*2, screw_diameter=0,length=d,x=w-wall,y=h-wall);
            
    }
    //screw holes
    if (top==1) translate([wall/2,wall/2,0]) screw_holes(post_diameter=r*2, screw_diameter=2.8,length=d-wall,x=w-wall,y=h-wall);
    if (top==0) {
        translate([wall/2,wall/2,0]) screw_holes(post_diameter=r*2, screw_diameter=screw_size*2,length=d-wall,x=w-wall,y=h-wall);
        translate([wall/2,wall/2,d-wall]) screw_holes(post_diameter=r*2, screw_diameter=screw_size,length=wall,x=w-wall,y=h-wall);
        
    }

    module outer(x,y,z,r) {
       hull() screw_holes(post_diameter=r*2,length=z,x=x,y=y);
    }

    module screw_holes(post_diameter, screw_diameter, length,x,y) {
        od = post_diameter;
        r = post_diameter/2;
        translate([r, r, o]) tube(od, screw_diameter, length);
        translate([x - r, y - r, o]) tube(od, screw_diameter, length);
        translate([x - r, o + r, o]) tube(od, screw_diameter, length);
        translate([o + r, y - r, o]) tube(od, screw_diameter, length);
    }
};

module holes(diameter, number = 1, spread = 0, depth=wall_thickness) {
    if (spread > 0) {
        spacing = spread / (number-1);
        translate([o, o, o]) for (i = [0: number-1]) {
            translate([0, i * spacing, 0]) cylinder(depth, d = diameter, $fn=circle_resolution);
        }
    }
    else {
        spacing = (diameter * 1.5);
        translate([diameter/2, diameter/2, o]) for (i = [0: number - 1]) {
            translate([0, i * spacing, 0]) cylinder(depth, d = diameter, $fn=circle_resolution);
        }
    }
}

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
    screen_screw_blocks(screw_size-.1,wall+screen_thickness+clearance,screen,wall);
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
    //gap for ribbon cable
    translate([33.5+wall_thickness,screw_size*2-wall_thickness,0]) cube([25,8,wall_thickness*4]);
  translate([23.5+wall_thickness,screw_size*2-wall_thickness,0]) cube([45,15,wall_thickness*2]);
  }
  //create screw lugs
  translate([screw_lug_offset,0,0]) screen_screw_blocks(screw_size+.2,wall_thickness*3,s,wall_thickness,screw_size*2);
}

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
