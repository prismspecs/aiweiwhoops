var imgsize = 142;
var urnCount = 0;

var urn = new Array();	// create array for urns

$("#container").mousemove(function(e){
      $('.follow').css({'top': e.clientY - imgsize/2, 'left': e.clientX - imgsize/2});
});

$("#container").click(function(e){
	var urn[urnCount] = {  //create an object to draw
  		x: e.clientX,  //x value
	  	y: e.clientY,  //y value
	}

	alert("yup");
});