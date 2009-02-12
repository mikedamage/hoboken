$(document).ready(function() {
	$("textarea").markItUp(mySettings);
	
	$("a[href^='http://']").addClass("external");
	$("a[href$='.pdf']").addClass("pdf_link").removeClass("external");
	
	
	$(".upload").hide();
	
	$('.upload_link').click(function() {
		$('.upload').toggle('fast');
	});
	
	$(".reset").live('click', function() {
		$(".status").hide("fast");
		$("#upload_form").show("fast");
	});
	
	/*$('#upload_form').ajaxForm({
		dataType: "xml",
		beforeSubmit: function(data, form, opts) {
			$(".working").show("normal");
		},
		success: function(json, status) {
			$(".working").hide("fast");
			$(".status").html(html);
			$(".status").show("fast");
		}
		
	});*/
});