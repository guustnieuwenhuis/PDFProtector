<cfwebsocket name="protect" onmessage="onMessageHandler">

<cfoutput>
	<div class="row">
		<div class="span12">
			<div class="row">
				<div class="span6">
					<h1>
						Protect PDF
					</h1>
					<form>
						<fieldset>
							<div class="control-group form-horizontal">
								<label class="control-label" for="select01">
									Document
								</label>
								<div class="controls">
									<cfdirectory action="list" directory="#ExpandPath('repository')#" name="files" 
									             filter="*.pdf">
									<select id="file">
										<cfloop query="files">
											<option>
												#files.name#
											</option>
										</cfloop>
									</select>
								</div>
							</div>
							<div class="control-group form-horizontal">
								<label class="control-label" for="addWatermark">
									Add watermark
								</label>
								<div class="controls">
									<label class="checkbox">
										<input type="hidden" id="addWatermark" value="true">
										<div class="btn-group" data-toggle="buttons-radio">
											<button class="btn btn-primary active" onclick="$('##addWatermark').val('true'); return false;">Yes</button>
											<button class="btn btn-primary" onclick="$('##addWatermark').val('false'); return false;">No</button>
										</div>
									</label>
								</div>
							</div>
							<div class="control-group form-horizontal">
								<label class="control-label" for="addFooter">
									Add footer
								</label>
								<div class="controls">
									<label class="checkbox">
										<input type="hidden" id="addFooter" value="true">
										<div class="btn-group" data-toggle="buttons-radio">
											<button class="btn btn-primary active" onclick="$('##addFooter').val('true'); $('##footerDetails').show(); return false;">Yes</button>
											<button class="btn btn-primary" onclick="$('##addFooter').val('false'); $('##footerDetails').hide(); return false;">No</button>
										</div>
									</label>
								</div>
							</div>
							<div id="footerDetails" class="offset2">
								<div class="control-group form-search">
									<label class="control-label" for="input01">
										Name
									</label>
									<div class="controls">
										<input type="text" class="input-xlarge" id="footerName">
									</div>
								</div>
							</div>
							<div class="form-actions form-horizontal">
								<button id="btnProtect" type="button" class="btn btn-primary">
									Protect
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
						<div id="protectProgress" class="progress active">
							<div id="protectProgressBar" class="bar" style="width: 0%;">
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
	$(document).ready(function(){
	    $("#btnProtect").click(function(){
	        var txt = document.getElementById("statusoverview");
	        $("#statusoverview").html("");
	        $("#protectProgressBar").width("10%");
	        $("#protectProgress").addClass("progress-striped");
	        protect.invoke('controllers.main', 'getMsg', [$('#file').val(), $('#addWatermark').val(), $('#addFooter').val(), $('#footerName').val()]);
	    });
	});
	function onMessageHandler(messageObject){
	    //JavaScript messageobject is converted to a string. 
	    var message = messageObject;
	    if (message.type == "data") {
	        var msg = message.data;
	        $("#protectProgressBar").width(msg.PROGRESS);
	        var txt = $("#statusoverview").html();
	        switch (msg.TYPE) {
	            case "error":
	                $("#statusoverview").html("<div class='alert alert-error'><button class='close' data-dismiss='alert'>×</button>" + msg.MESSAGE + "</div>" + txt);
	                break;
	            case "status":
	                $("#statusoverview").html("<div class='alert alert-success'><button class='close' data-dismiss='alert'>×</button>" + msg.MESSAGE + "</div>" + txt);
	                break;
	            case "download":
	                $("#statusoverview").html("<div class='thumbnail'><img src='" + msg.THUMB + "'><div class='caption'><a target='_blank' href='" + msg.URL + "' class='btn btn-primary'>Download PDF</a></div></div>" + txt);
	                break;
	        }
	        if (msg.PROGRESS == "100%") {
	            $("#protectProgress").removeClass("progress-striped");
	        }
	    }
	}
</script>