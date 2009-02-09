$(document).ready(function() {
	$("textarea").markItUp(mySettings);
	
	$(".upload").hide();
	
	$('.upload_link').click(function() {
		$('.upload').toggle('fast');
	});
	
	if ( window.location.href.match(/upload/) ) {
		$("#submit").click(function() {
			$.ajaxFileUpload({
				url: '/upload',
				secureuri: false,
				fileElementId: 'data',
				dataType: 'json',
				beforeSend: function() {
					$("fieldset").hide();
					$(".loading").show('fast');
				},
				complete: function() {
					$(".loading").hide('slow');
				},
				success: function(data, status) {
					console.log(data);
					console.log(status);
				},
				error: function(data, status, e) {
					console.error(e);
				}
			});
		});
	}
});