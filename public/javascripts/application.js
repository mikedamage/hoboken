$(document).ready(function() {
	$("textarea").markItUp(mySettings);
	
	$(".upload").hide();
	
	$('.upload_link').click(function() {
		$('.upload').toggle('fast');
	});
	
	$(".reset").live('click', function() {
		$(".status").hide("fast");
		$("#upload_form").show("fast");
	});
	
	$('#upload_form').ajaxForm({
		target: "#upload_status",
		dataType: "json",
		beforeSubmit: function(data, form, opts) {
			$(".working").show("fast");
			$("#upload_form").hide("fast");
		},
		success: function(response, status) {
			$(".working").hide("fast");
			$("#upload_status .status").html(response);
			$("#upload_status .status").show("fast");
		}
		
	});
});