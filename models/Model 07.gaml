model tutorial_gis_city_traffic

global {
    file shape_file_buildings <- file("../includes/polyfinal.shp");
    file shape_file_roads <- file("../includes/finalroad.shp");
    file station <- file("../includes/landmarks.shp");
    file shape_file_bounds <- file("../includes/bounds.shp");
    geometry shape <- envelope(shape_file_buildings);
    geometry roadno  <- envelope(shape_file_roads);
    float step <- 1#sec;
    
    date starting_date <- date("2024-09-01 06:00:00");	
    int nb_people <- 1000;
    float min_work_start <- 6.0;
    float max_work_start <- 8.0;
    float min_work_end <- 16.0 ; 
    int max_work_end <- 18; 
    float min_speed <- 0.000000001710 #km / #s;
    float max_speed <- 0.00000002459 #km / #s;
    
    float destroy <- 0.02;
    int repair_time <- int(2 #minute) ;
    graph the_graph;
    int road_degradation_interval <- 1;
	point test;
	int case  <- 0;
	float side_length <- 0.0002; // Length of the side of the square
	bool   up <-   false;
    bool   stacruz <-   false;
    bool   calamba <-   false;
    bool   malinta <-   false;
    int flag;
    int bahay;
    int  workbuild;
    int  day;
    float  trafficdur   <-  240#s;
    
    init {
    	
	create building from: shape_file_buildings with: [type::string(read ("NATURE"))] {
	    if type="Industrial" {
		color <- #blue ;
	    }
	}
	current_date <- date("2024-09-01-06-00-00");
	
	create stations from:  station;
	
	create road from: shape_file_roads ;
	
    the_graph <- as_edge_graph(road);

    
	
	
	
	create squareako {
    
   location  <- {0.00292586559734787,0.0013556504228518};
}   

	
    create passerby  number: 200
    {
    	yes  <-  rnd(min_speed,max_speed);
    	speed  <-  yes;
    	location <- any_location_in (one_of(station)); 
    	object  <-  "route1";
    	
    }
	//map<road,float> weights_map <- road as_map (each:: (each.destruction_coeff * each.shape.perimeter));
	the_graph <- as_edge_graph(road); //with_weights weights_map;	
		
	list<building> residential_buildings <- building where (each.type="Residential");
	list<building> industrial_buildings <- building  where (each.type="Industrial") ;
	create people number: nb_people {
	    yes  <-  rnd(min_speed,max_speed);   //rnd(0.0003,0.0001);
	    speed <- yes;  //rnd(min_speed, max_speed);
	    start_work <- int(rnd (min_work_start, max_work_start));
	    end_work <- rnd(min_work_end, max_work_end);
	    living_place <- one_of(residential_buildings) ;
	    working_place <- one_of(industrial_buildings) ;
	    objective <- "resting";
	    
	    
	    location <- any_location_in (one_of(station)); 
	    //min_security_distance <- 0.05;
	    //safe_distance <- 5.0;
	    currentloc1 <- self get 'location';
	}
    }
	
   // reflex update_graph{
	//map<road,float> weights_map <- road as_map (each:: (each.destruction_coeff * each.shape.perimeter));
	//the_graph <- the_graph with_weights weights_map;
   // }
	 reflex aa when: every(trafficdur) {
      case <- case + 1;
      if (case > 5) { // Reset case after it reaches 3
        case <- 0;
      }
    }
    //reflex repair_road when: every(1200 #sec) 
    //{
   
	//road the_road_to_repair <- road with_max_of (each.destruction_coeff) ;
	//ask the_road_to_repair {
	//    destruction_coeff <- 1.0 ;
	//}
   // }
    
    reflex when: current_date.hour = 0
    {
    	
    	day <- day + 1;
    }
  
}

species building {
    string type; 
    rgb color <-   #pink ;
	
	
    aspect base {
	draw shape color: rgb("#999188") border: #black; 
    }
}

species  stations
{
	rgb color;	
	aspect base {
		draw shape color: rgb("#756e66") border:  #black;
	}
}

species road  {
    float destruction_coeff <- 1.0; //rnd(1.0,2.0) max: 2.0;
    int colorValue <- int(255*(destruction_coeff - 1)) update: int(255*(destruction_coeff - 1));
    rgb color <- rgb(53, 64, 42) update: destruction_coeff < 2 ? rgb(53, 64, 42) : rgb(min([255, colorValue]), max ([0, 255 - colorValue]), 0);
    //rgb color <- rgb(min([255, colorValue]),max ([0, 255 - colorValue]),0)  update: rgb(min([255, colorValue]),max ([0, 255 - colorValue]),0) ;
  	bool one_way <- false;
  	point start_point;//<-  {0.0029578328007318078,0.0014023884308098644,0.0};
  	point end_point ;//<-   {0.005233786702817156,0.0018462427099770196,0.0};
  	bool redlight <- false;
  	bool blocked <- false;
	string road_name <- self get 'name'; 
	point road_loc <- self get 'location'; 
	int population <- 0;
    
    init {
    	one_way  <-true;
    	if (not empty(shape.points))
    	{
    	start_point <- shape.points[0];
        end_point <- shape.points[1];
        write road_name + " start: " +start_point;
        write  road_name + " last: "  + end_point;
        test   <-  start_point;
        //if road_name = "road11"
        //{
    	//self.start_point <- {0.0029578328007318078,0.0014023884308098644,0.0};
    	//self.start_point  <- {0.005233786702817156,0.0018462427099770196,0.0};
       // }
    	}
        
    }
  
    aspect base {
	draw shape color: color   width:  3.5 ;
    }
    
    reflex  bilang
    {
    	
    	
    	
    	
    }
    reflex trafficflow{
     switch case {
     	match  1
     	{
     		write  "starting "+  current_date;
     		up  <-   false;
    	stacruz  <-  false;
    	malinta  <-  false;
    	calamba <- false;
    	destruction_coeff <-  1.0;
     	}
      match  2{
      	if(road_name = "road2" or road_name =  "road1"  or road_name  = "road9")
    {
    	write  "from  calamba  to sta    cruz   GO! "+  current_date;
    	destruction_coeff <-  2.0;
    	calamba <-   true;
    }
    else
    {
    	up  <-   false;
    	stacruz  <-  false;
    	malinta  <-  false;
    	destruction_coeff <-  1.0;
    }
      }
      match 3{
      	if(road_name = "road0" or road_name =  "road2"  or road_name  = "road9")
    {
    	write  "from  malinta  to junction   GO! " +  current_date;
    	destruction_coeff <-  2.0;
    	malinta <-   true;
    	}
    	else
    	{
    		destruction_coeff <-  1.0;
    		up  <-   false;
    	stacruz  <-  false;
    	calamba  <-  false;
    	}
      }
      match 4
      {
      	if(road_name = "road1" or road_name =  "road0"  or road_name  = "road2")
    {
    	write  "from  sta  cruz  to calamba  GO! " +  current_date;
    	destruction_coeff <-  2.0;
    	stacruz <-   true;
    	}
    	else
   	{
    		destruction_coeff <-  1.0;
    		up  <-   false;
    	calamba  <-  false;
    	malinta  <-  false;
    	}
      }
      match 5
      {
      	if(road_name = "road9" or road_name =  "road0"  or road_name  = "road1")
    {
    	write  "from  uplb  to junction   GO! " +  current_date;
    	destruction_coeff <-  2.0;
    	up <-   true;
    	}
    	else
    	{
    		destruction_coeff <-  1.0;
    		calamba  <-   false;
    	stacruz  <-  false;
    	malinta  <-  false;
    	}
      }
    }
    
   
    }
     	
     
    
}
species squareako {
    
  	
    aspect base {
        draw circle(0.000000000000000001) color: #white border:  #black at: location;
    }
}

species passerby skills: [moving]
{
	float yes;
	point the_target2 <-  nil;
	string  object;
	road current_road <- nil;
	
	reflex  assigntar   when:  object =  "route1" 
	{
		object  <-   "route2";
		the_target2  <- any_location_in(one_of(building));
		
		 if the_target2.x > location.x {
        // If the target is also in the positive y direction
        if the_target2.y > location.y {
           location  <-  {0.003308252937856082,0.002742121750001658,0.0};
          
        } 
        // If the target is in the negative y direction
        else if the_target2.y < location.y {
           location  <-{0.002718803826127214,4.528853416108092E-4,0.0};
        }
    } 
    // If the target is in the negative x direction
    else if the_target2.x < location.x {
        // If the target is also in the positive y direction
        if the_target2.y > location.y {
           location   <-  {0.0052446559772221235,0.001815725131853796};
        } 
        // If the target is in the negative y direction
        else if the_target2.y < location.y {
            location  <- {9.51282053875957E-5,9.064685233326486E-4,0.0};
        }
    }
    
	}
	reflex  assigntar2   when:  object =  "route2"   and  every(700 #sec)
	{
		object  <-   "route1";
		the_target2  <- any_location_in(one_of(building));
		 if the_target2.x > location.x {
        // If the target is also in the positive y direction
        if the_target2.y > location.y {
           location  <-  {0.003308252937856082,0.002742121750001658,0.0};
          
        } 
        // If the target is in the negative y direction
        else if the_target2.y < location.y {
           location  <-{0.002718803826127214,4.528853416108092E-4,0.0};
        }
    } 
    // If the target is in the negative x direction
    else if the_target2.x < location.x {
        // If the target is also in the positive y direction
        if the_target2.y > location.y {
           location   <-  {0.0052446559772221235,0.001815725131853796};
        } 
        // If the target is in the negative y direction
        else if the_target2.y < location.y {
            location  <- {9.51282053875957E-5,9.064685233326486E-4,0.0};
        }
    }
    
	}
	reflex move when: the_target2 != nil
	{
		path path_followed <- goto(target: the_target2, on: the_graph, return_path: true);
		list<geometry> segments <- path_followed.segments;
			list<people> closest_people <- list<people>((people where (each != self)) closest_to self);
			
            loop line over: segments {
             current_road <- road(path_followed agent_from_geometry line);
                 float distance_to_intersection <- distance_to(self.location, {0.00292586559734787,0.0013556504228518});
                current_road <- road(path_followed agent_from_geometry line);
	        	if current_road.destruction_coeff = 2.0  and  distance_to_intersection < 0.001
                	{
                		
                	    
                		speed <- yes;
                		if distance_to_intersection < 0.0001
                		{
                			speed  <-  0.0;
                		}
                		else if distance_to_intersection < 0.0002
                		{
                			speed  <-  min_speed;
                		}
                		 else if distance_to_intersection < 0.0003 {
		                speed <- 0.0000002; // Adjust this value as needed
		                }
           
                		
                		
                		
                	
                		
                	}
                	else
                	{
                		speed  <- yes ;
                	}
                	
                	}
		if  the_target2 =   location
		{
			the_target2  <- nil;
		}
		
	}
	aspect base {
        draw circle(0.00002) color: #pink border:  #black;
    }
    
    
}

species people skills: [moving] {
    rgb color <- #yellow;
    building living_place <- nil;
    building working_place <- nil;
    int start_work;
    int end_work;
    string objective;
    point the_target <- nil;
    point previous_location <- nil;
	list<road> selected_roads2;
	point currentloc1;
	road current_road <- nil;
	float safe_distance <- 0.00001; 
	
	float  yes;
	
	float   malapit;
	
	
    reflex update_previous_location 
    
    
    {
        previous_location <- currentloc1;  // Update previous_location at each step
    }

    reflex time_to_work when: current_date.hour = start_work and objective = "resting" {
    	write day;
        objective <- "working";
        the_target <- any_location_in(one_of(building));
        
        currentloc1 <- self get 'location';
        if the_target.x > location.x {
        // If the target is also in the positive y direction
        if the_target.y > location.y {
           location  <-  {0.003308252937856082,0.002742121750001658,0.0};
          
        } 
        // If the target is in the negative y direction
        else if the_target.y < location.y {
           location  <-{0.002718803826127214,4.528853416108092E-4,0.0};
        }
    } 
    // If the target is in the negative x direction
    else if the_target.x < location.x {
        // If the target is also in the positive y direction
        if the_target.y > location.y {
           location   <-  {0.0052446559772221235,0.001815725131853796};
        } 
        // If the target is in the negative y direction
        else if the_target.y < location.y {
            location  <- {9.51282053875957E-5,9.064685233326486E-4,0.0};
        }
    }
    }

    reflex time_to_go_home when: current_date.hour = end_work and objective = "working" {
    	
        objective <- "resting";
        the_target <- any_location_in(one_of(station));
        currentloc1 <- self get 'location';
        
        if the_target.x > location.x {
        // If the target is also in the positive y direction
        if the_target.y > location.y {
           location  <-  {9.51282053875957E-5,9.064685233326486E-4,0.0};
        } 
        // If the target is in the negative y direction
        else if the_target.y < location.y {
           location  <- any_location_in({0.002718803826127214,4.528853416108092E-4,0.0});
        }
    } 
    // If the target is in the negative x direction
    else if the_target.x < location.x {
        // If the target is also in the positive y direction
        if the_target.y > location.y {
           location   <-  any_location_in({0.0052446559772221235,0.001815725131853796});
        } 
        // If the target is in the negative y direction
        else if the_target.y < location.y {
            location  <- any_location_in({9.51282053875957E-5,9.064685233326486E-4,0.0});
        }
    }
    }
    
    reflex distansya
    {
    	//list<people> closest_people <- list<people>((people where (each != self)) closest_to self);
    	//loop p over: closest_people {
        //if (distance_to(p, self) < 0.00002) { // If another agent is too close
       // point away <- self.location - p.location; // Calculate a direction away from the other agent
       // speed <- 0.0000001;
        
    // }
    // else
    // {
     //	speed <- yes;
    // }
  //  }
   
   		
    }

    reflex check_direction {
        if previous_location != nil {
            if location.x > previous_location.x {
                // Moving in positive x direction
                //speed <-  0.0;
              
                
            } else if location.x < previous_location.x {
                // Moving in negative x direction
            }

            if location.y > previous_location.y {
                // Moving in positive y direction
            } else if location.y < previous_location.y {
                // Moving in negative y direction
            }
        }
    }
   

    reflex move when: the_target != nil {
    	     
    	    //float malapit <- distance_to(self.location, {0.00292586559734787,0.0013556504228518});
    		
    		//write  "count: "   +  flag;
        //if the_target.y < 0.0013556504228518 {
          //  selected_roads <- road where (each.road_name = "road7"  or each.road_name = "road2");
        //} else if the_target.y > 0.0013556504228518 {
        //    selected_roads <- road where (each.road_name = "road5" or each.road_name = "road1");
      //  }
      		
        
            //graph new_graph <- as_edge_graph(selected_roads);
            
            path path_followed <- goto(target: the_target, on: the_graph, return_path: true);
            list<geometry> segments <- path_followed.segments;
			list<people> closest_people <- list<people>((people where (each != self)) closest_to self);
            loop line over: segments {
            
                current_road <- road(path_followed agent_from_geometry line);
                 float distance_to_intersection <- distance_to(self.location, {0.00292586559734787,0.0013556504228518});
    	  
    	     
                if current_road != nil {
                
                	
                	agent var0 <- agent_closest_to(self);
                	//write var0;
                	loop p over: closest_people {
                	if current_road.destruction_coeff = 2.0  and  distance_to_intersection < 0.001
                	{
                		
                	    
                		speed <- rnd(0.000001,0.000002);
                		if distance_to_intersection < 0.0001
                		{
                			speed  <-  0.0;
                		}
                		else if distance_to_intersection < 0.0002
                		{
                			speed  <-  min_speed;
                		}
                		 else if distance_to_intersection < 0.0003 {
		                speed <- 0.0000002; // Adjust this value as needed
		                }
           
                		
                		
                		
                	
                		
                	}
                	else
                	{
                		speed  <- yes ;
                	}
                	
                	}
                    // Handle road logic, e.g., speed adjustment
                    if the_target = location {
                        the_target <- nil;
                       current_road <- nil;
                    }
                   
                }
            }
        
    }

    aspect base {
        draw circle(0.00002) color: color border: #black;
    }
}


experiment road_traffic type: gui {
   
parameter "People" var: nb_people category: "People" min: 300 max: 1000;
	parameter "Cycle" var: step category: "People" min: 1.0 max: 60.0;
	parameter "Speed" var: min_speed category: "People" min: 0.000000001700 #km / #s max:0.000003459 #km / #s;
	parameter "Time" var: current_date category: "People" min: date("2024-09-01 06:00:00") max: date("2024-09-01 00:00:00");
    output {
	display city_display type:opengl {
	    species building aspect: base ;
	    species road aspect: base ;
	    species people aspect: base ;
	    species stations aspect: base;
	    species squareako aspect: base;
	    species passerby aspect:base;
	}
	display chart_display refresh: every(1#cycles) { 
	    chart "Road Status" type: series size: {1, 0.5} position: {0, 0} {
		data "Road Population" value: people  count  (each.current_road != nil) style: line color: #green ;
		data "Time" value: current_date.hour color: #blue;
		
	    }
	    chart "People Objectif" type: pie style: exploded size: {1, 0.5} position: {0, 0.5}{
		data "Working" value: people count (each.objective="working") color: #magenta ;
		data "Resting" value: people count (each.objective="resting") color: #blue ;
		data "ROAD Population" value:  people  count  (each.current_road != nil) color:  #green;
	    }
	    
	    chart "my_chart" type: histogram  size: {1, 0.5} position: {0, 0} {
data  "Time" value: float(current_date.hour) color:  #blue;
		data  "People" value:  people  count  (each.current_road != nil) color:  #magenta;
	   }
	}
	
    }
}