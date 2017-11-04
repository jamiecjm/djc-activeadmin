

$(document).ready(function(){
	Chartkick.eachChart( function(chart) {
	  // do something
	  $(window).resize(function(){
	  	chart.redraw();
	  })
	})
})