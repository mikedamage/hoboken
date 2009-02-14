$(document).ready(function() {
	$("textarea").markItUp(mySettings);
	
	$("a[href^='http://']").addClass("external");
	$("a[href$='.pdf']").addClass("pdf_link").removeClass("external");
	
	$("a.hide").live('click', function() {
		$("#file_browser").hide("slide", {direction: 'right', duration: 1500, easing: 'easeOutBounce'});
		return false;
	});
	
	fileBrowser = false;
	
	$(".get_files").click(function() {
		if (fileBrowser) {
			$("#file_browser").toggle("slide", {direction: 'right', duration: 1500, easing: 'easeOutBounce'});
			return false;
		} else {
			// get JSON list of available files and fill file browser list
			$.get("/files", {}, function(json) {
				for(i=0;i<json.files.length;i++) {
					$("#file_browser ul").append('<li name="'+json.files[i].ext+'">'+json.files[i].name+"</li>");
					console.log("File: "+json.files[i].name+", Extension: "+json.files[i].ext);
				}
				// make the list items draggable
				$("#file_browser ul li").draggable({
					helper: 'clone',
					opacity: 0.7
				});
			}, 'json');
		
		
		
			// make the textarea droppable - this is the tricky part.
			$("textarea#body").droppable({
				accept: "li",
				drop: function(event, ui) {
					// $(this) is the textarea
					// $(ui.draggable) is the list item being dropped
					var text = $(this).val();
					var dragClass = $(ui.draggable).attr('name');
					var dragFile = $(ui.draggable).text();
					var imgFormats = ["bmp", "gif", "jpg", "jpeg", "png"];
				
					if ( $.inArray(dragClass, imgFormats) != -1 ) {
						var imgTag = '{{'+dragFile+'}}';
						$(this).val(text + "\n" + imgTag);
						$(ui.helper).hide();
					} else {
						var linkTag = "[[/files/"+dragFile+"]]";
						$(this).val(text + "\n" + linkTag);
						$(ui.helper).hide();
					}
				}
			});
		
			$("#file_browser").show("slide", { direction: 'right', easing: 'easeOutBounce', duration: 1500});
			fileBrowser = true;
			return false;
		}
	});
	
});