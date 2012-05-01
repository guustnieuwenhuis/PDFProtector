component
{

	public any function init(fw)
	{
		variables.fw = fw;
		return this;
	}
	
	public void function default(rc)
	{
	}
	
	public void function protect(rc)
	{
	}
	
	public void function upload(rc)
	{
		rc.uniquechannel = "upload.#CreateUUID()#";
	}
	
	public void function uploadDocs(rc)
	{
		try {
			local.file = fileUpload(ExpandPath('repository/'), "file", "application/pdf", "MakeUnique", true);
			
			local.response = StructNew();
			local.response.type = "status";
			local.response.message = "#local.file.clientfilename# uploaded as #local.file.serverfile#";
			local.response.progress = "100%";
			WSPublish(rc.channel,local.response);
		}
		catch(any ex) {
			local.response = StructNew();
			local.response.type = "error";
			local.response.message = "Something went wrong... #ex.message#";
			local.response.progress = "0%";
			WSPublish(rc.channel,local.response);
		}
	}
	
	public void function getMsg(file, addWatermark, addFooter, footerName)
	{
		try {
			local.UUID = CreateUUID();
			local.filename = local.UUID & ".pdf";
			local.filePath = ExpandPath('../temp/#local.filename#');
			local.pdf = new pdf();

			fileCopy(ExpandPath('../repository/#arguments.file#'),local.filePath);
			
			local.response = StructNew();
			local.response.type = "status";
			local.response.message = "PDF copied";
			local.response.progress = "25%";
			WSSendMessage(local.response);

			local.text = local.pdf.extractText(source=local.filepath, pages="1-10");
			
			local.response = StructNew();
			local.response.type = "status";
			local.response.message = "Text extracted";
			local.response.progress = "40%";
			WSSendMessage(local.response);

			local.detector = application.detectorFactory.create();
			
			local.detector.append(REReplace(local.text, '<[^>]*>', '', 'all'));
			local.language = detector.detect();

			local.response = StructNew();
			local.response.type = "status";
			local.response.message = "Language detected: #local.language#";
			local.response.progress = "55%";
			WSSendMessage(local.response);
			
			setLocale(application.locale[UCase(local.language)]);
			
			if(arguments.addWatermark) {
				
				local.pdf.addWatermark(source=local.filepath, image=ExpandPath("../img/#UCase(local.language)#.jpg"));
				
				local.response = StructNew();
				local.response.type = "status";
				local.response.message = "Watermark added";
				local.response.progress = "70%";
				WSSendMessage(local.response);
			}
			
			if(arguments.addFooter) {
				
				local.footerText = application.labels[UCase(local.language)].footer;
				local.footerText = Replace(local.footerText, "*name*", arguments.footerName);
				local.footerText = Replace(local.footerText, "*date*", LSDateFormat(Now(), "long"));
				local.footerText = "<span style='font-size: 6;'>" & local.footerText & "</span>";
				local.pdf.addFooter(source=local.filepath, text=local.footerText);
				
				local.response = StructNew();
				local.response.type = "status";
				local.response.message = "Footer added";
				local.response.progress = "85%";
				WSSendMessage(local.response);
			}
			
			local.pdf.thumbnail(source=local.filepath, format="png", pages="1", destination=ExpandPath('../temp/thumb-#local.UUID#/'));

			local.response = StructNew();
			local.response.type = "status";
			local.response.message = "PDF protected!";
			local.response.progress = "100%";
			WSSendMessage(serializeJSON(local.response));
			
			local.response = StructNew();
			local.response.type = "download";
			local.response.thumb = "#application.pathToPDFProtector#temp/thumb-#local.UUID#/#local.UUID#_page_1.png";
			local.response.url = "#application.pathToPDFProtector#temp/#local.filename#";
			local.response.progress = "0%";
			WSSendMessage(serializeJSON(local.response));
		}
		catch(any ex) {
			local.response = StructNew();
			local.response.type = "error";
			local.response.message = "Something went wrong... #ex.message#";
			local.response.progress = "0%";
			WSSendMessage(serializeJSON(local.response));
		}
	}
	
}