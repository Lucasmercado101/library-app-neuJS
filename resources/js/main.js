Neutralino.init();

Neutralino.events.on("windowClose", () => Neutralino.app.exit());

// async function readFile() {
//   let entries = await Neutralino.os.showOpenDialog("Read your JSON file", {
//     filters: [{ name: "All files", extensions: ["txt", "json"] }]
//   });
//   if (!entries[0]) return;
//   const file = entries[0];
//   const data = await Neutralino.filesystem.readFile(file);
//   console.log(JSON.parse(data));
// }

// readFile();

const app = Elm.Main.init({
  node: document.getElementById("main")
});

app.ports.sendRequestBooks.subscribe(async function () {
  try {
    const books = await Neutralino.storage.getData("books");
    return app.ports.booksReceiver.send(books);
  } catch (e) {
    return app.ports.booksReceiver.send([]);
    // TODO: handle error
    // if (e?.code == "NE_ST_NOSTKEX") {
    // } else {
    //   return app.ports.booksReceiver.send([]);
    // }
  }
});

app.ports.sendCreateNewBook.subscribe(async function (book) {
  try {
    let books = [];
    try {
      books = await Neutralino.storage.getData("books");
    } catch (e) {
      // TODO: handle error
    }
    books.push(book);
    await Neutralino.storage.setData("books", JSON.stringify(books));
    return app.ports.booksReceiver.send(books);
  } catch (e) {
    // TODO: handle error
    // return app.ports.booksReceiver.send([]);
  }
});
