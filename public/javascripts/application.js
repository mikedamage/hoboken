$(document).ready(function() {
	$("textarea").markItUp(mySettings);
	
	$("a[href^='http://']").addClass("external");
	$("a[href$='.pdf']").addClass("pdf_link").removeClass("external");
	
	$(".get_files").click(function() {
		// get JSON list of available files and fill file browser list
		$.get("/files", {}, function(json) {
			for(i=0;i<json.files.length;i++) {
				$("#file_browser ul").append('<li class="'+json.files[i].ext+'">'+json.files[i].name+"</li>");
			}
		}, 'json');
		
		// make the list items draggable
		$("#file_browser ul li").draggable({
			helper: 'clone',
			opacity: 0.7
		});
		
		// make the textarea droppable - this is the tricky part.
		$("textarea#body").droppable({
			accept: "li",
			drop: function() {
				// $(this) is the textarea
				// $(ui.draggable) is the list item being dropped
			}
		});
	});
	
});