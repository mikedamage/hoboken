$(document).ready(function() {
	$("textarea").markItUp(mySettings);
	
	$(".upload").hide();
	
	$('.upload_link').click(function() {
		$('.upload').toggle('fast');
	});
	
	$('button.submit').click(function() {
		$.post('/upload', {})
	});
});