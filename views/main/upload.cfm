<cfwebsocket name="upload" onmessage="onMessageHandler">

<cfoutput>
	<div class="row">
		<div class="span12">
			<div class="row">
				<div class="span6">
					<h1>
						Upload
					</h1>
					<form id="frmUpload" enctype="multipart/form-data">
						<fieldset>
							<div class="control-group form-horizontal">
								<label class="control-label" for="fileInput">
									File input
								</label>
								<div class="controls">
									<input class="input-file" id="file" name="file" type="file" accept="application/pdf">
								</div>
							</div>
							<div class="form-actions form-horizontal">
								<button id="btnUpload" type="button" class="btn btn-primary">
									Upload
								</button>
							</div>
						</fieldset>
					</form>
				</div>
				<div class="span6">
					<h1>
						Status
					</h1>
					<div class="well">
						<div id="uploadProgress" class="progress active">
							<div id="uploadProgressBar" class="bar" style="width: 0%;">
							</div>
						</div>
						<div id="statusoverview">
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</cfoutput>

<script>
	var uniquechannel = "<cfoutput>#rc.uniquechannel#</cfoutput>";
	
	$(document).ready(function(){
	    $("#btnUpload").click(function(){
	        var txt = document.getElementById("statusoverview");
	        $("#uploadProgress").addClass("progress-striped");
			
			upload.subscribe(uniquechannel);
			
		    var formData = new FormData($('form')[0]);
			formData.append('channel', uniquechannel);
		    $.ajax({
		        url: '<cfoutput>#BuildUrl("main.uploadDocs")#</cfoutput>',  //server script to process data
		        type: 'POST',
		        xhr: function() {  // custom xhr
		            myXhr = $.ajaxSettings.xhr();
		            if(myXhr.upload){ // check if upload property exists
		                myXhr.upload.addEventListener('progress',progressHandler, false); // for handling the progress of the upload
		            }
		            return myXhr;
		        },
		        //Ajax events
		        success: progressCompleteHandler,
		        // Form data
		        data: formData,
		        //Options to tell JQuery not to process data or worry about content-type
		        cache: false,
		        contentType: false,
		        processData: false
		    });
	    });
	});
	function progressHandler(e){
	    if(e.lengthComputable){
			$("#uploadProgressBar").width(e.loaded / e.total * 100 + "%");
	    }
	}
	function progressCompleteHandler(e){
		$("#uploadProgress").removeClass("progress-striped");
	}
	function onMessageHandler(messageObject){
	    //JavaScript messageobject is converted to a string. 
	    var message = messageObject;
	    if (message.type == "data") {
	        var msg = $.parseJSON(message.data);
	        $("#uploadProgressBar").width(msg.PROGRESS);
	        var txt = $("#statusoverview").html();
	        switch (msg.TYPE) {
	            case "error":
	                $("#statusoverview").html("<div class='alert alert-error'><button class='close' data-dismiss='alert'>×</button>" + msg.MESSAGE + "</div>" + txt);
	                break;
	            case "status":
	                $("#statusoverview").html("<div class='alert alert-success'><button class='close' data-dismiss='alert'>×</button>" + msg.MESSAGE + "</div>" + txt);
	                break;
	        }
	        if (msg.PROGRESS == "100%") {
	            $("#uploadProgress").removeClass("progress-striped");
	        }
	    }
	}
</script>