{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  onEntrypointLoaded: async function(engineInitializer) {
    let appRunner = async function() {
      let engine = await engineInitializer.initializeEngine({
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
