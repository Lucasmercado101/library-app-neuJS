Neutralino.init();

Neutralino.events.on("windowClose", () => Neutralino.app.exit());

Elm.Main.init({
  node: document.getElementById("main")
});
