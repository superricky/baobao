
function date_to_HHMM(date){
	var hh = date.getHours();
	var mm = date.getMinutes();
	// These lines ensure you have two-digits
	if (hh < 10) {hh = "0"+hh;}
	if (mm < 10) {mm = "0"+mm;}
	// This formats your string to HH:MM:SS
	var t = hh+":"+mm;
	return t;
}

$(document).ready(function(){
	var csrfToken = $("meta[name='csrf-token']").attr("content");
	$.ajaxSetup({
	  headers: {
	    'X-CSRF-Token': csrfToken
	  }
	});
});