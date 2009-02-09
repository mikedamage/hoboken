$(document).ready(function() {
	$("textarea").markItUp(mySettings);
	
	$(".upload").hide();
	
	$('.upload_link').click(function() {
		$('.upload').toggle('fast');
	});
	
	if ( window.location.href.match(/upload/) ) {
		
	}
});