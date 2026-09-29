{{flutter_js}}
{{flutter_build_config}}

// Keep the loading screen up until the app is running.
_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();
    document.getElementById("loading")?.remove();
  },
});
