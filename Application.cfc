component extends="org.corfield.framework" {
	
	this.name = "PDFProtector";
	this.javaSettings = {LoadPaths = ["/lib"], loadColdFusionClassPath = true, reloadOnChange = true, watchInterval = 100, watchExtensions = "jar"};
	this.wschannels=[{name = "upload"}];
	
	variables.framework = {
		// whether or not to use subsystems:
		usingSubsystems = false,
		// the URL variable to reload the controller/service cache:
		reload = 'reload',
		// the value of the reload variable that authorizes the reload:
		password = 'true',
		// debugging flag to force reload of cache on each request:
		reloadApplicationOnEveryRequest = true
	};
	
	function setupRequest() {
		// use setupRequest to do initialization per request
		request.context.startTime = getTickCount();
		if(StructKeyExists(url, variables.framework.reload) AND url[variables.framework.reload] EQ variables.framework.password) {
			setupApplication();
		}
	}
	
	function setupApplication() {
		application.name = "PDFProtector";
		application.pathToPDFProtector = "http://localhost:8501/PDFProtector/";
		
		application.detectorFactory = CreateObject("java", "com.cybozu.labs.langdetect.DetectorFactory");
		try {
			application.detectorFactory.loadProfile(ExpandPath("lib/profiles"));
		}
		catch(any ex) {
		}
		
		application.labels = {
			EN = {
				footer = "This material is copyright and is licensed for the sole use by *name* on *date*"
			},
			FR = {
				footer = "Ce matériel est protégé par droit d'auteur et est autorisé à l'usage exclusif par *name* sur *date*"
			},
			NL = {
				footer = "Dit materiaal is auteursrechtelijk beschermd en in licentie gegeven voor exclusieve gebruik aan *name* op *date*"
			}
		};

		application.locale = {
			EN = "English (UK)",
			FR = "French (Standard)",
			NL = "Dutch (Standard)"
		};
		
	}
	
}