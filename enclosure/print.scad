// LetterBlock.scad - Basic usage of text() and linear_extrude()
// Module instantiation
myblock(2,97,54,6,3);

// Module definition.
// size=30 defines an optional parameter with a default value.
module myblock(height,width,depth, standoff_width, standoff_height) {
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






    
//    difference() {
 //       
  //      translate([0,0,size/6]) {
   //         // convexity is needed for correct preview
    //        // since characters can be highly concave
     //       linear_extrude(height=size, convexity=4)
      //          text(letter, 
       //              size=size*22/30,
        //             font="Calibrib",
         //            halign="center",
          //           valign="center");
        //}
    //}