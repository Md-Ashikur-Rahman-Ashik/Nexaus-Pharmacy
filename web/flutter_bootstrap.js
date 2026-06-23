{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.loadEntrypoint({
  onEntrypointLoaded: async function(engineInitializer) {
    let appRunner = async function() {
      let engine = await engineInitializer.initializeEngine({
        // THIS IS THE MAGIC LINE THAT SKIPS THE HEAVY DOWNLOAD
        renderer: "html"
      });
      await appRunnerEngine(app);
    };
    if (window._flutter) {
      window._flutter.appRunner = appRunner;
    } else {
      window._flutter = { appRunner: appRunner };
      appRunner();
    }
  }
});
