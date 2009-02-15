$(document).ready(function() {
	$("textarea").markItUp(mySettings);
	
	$("a[href^='http://']").addClass("external");
	$("a[href$='.pdf']").addClass("pdf_link").removeClass("external");
	
	$("a.hide").live('click', function() {
		$("#file_browser").hide("slide", {direction: 'right', duration: 1500, easing: 'easeOutBounce'});
		return false;
	});
	
	fileBrowser = false;
	imgFormats = ["bmp", "gif", "jpg", "jpeg", "png"];
	
	$(".get_files").click(function() {
		if (fileBrowser) {
			$("#file_browser").toggle("slide", {direction: 'right', duration: 1500, easing: 'easeOutBounce'});
			return false;
		} else {
			// get JSON list of available files and fill file browser list
			$.get("/files", {}, function(json) {
				for(i=0;i<json.files.length;i++) {
					var file = json.files[i];
					$("#file_browser ul").append('<li class="'+file.class+'">'+file.name+"</li>");
					console.log("File: "+file.name+", Extension: "+file.ext+", Class: "+file.class);
				}
				
				// make the list items draggable
				$("#file_browser ul li").draggable({
					helper: 'clone',
					opacity: 0.7,
					cursor: 'move',
					revert: 'invalid'
				});
			}, 'json');
		
			$("textarea#body").droppable({
				accept: "li",
				drop: function(event, ui) {
					// $(this) == the textarea
					// $(ui.draggable) == the list item being dropped
					var text = $(this).val();
					var dragClass = $(ui.draggable).attr('class').split(' ');
					var dragFile = $(ui.draggable).text();
				
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