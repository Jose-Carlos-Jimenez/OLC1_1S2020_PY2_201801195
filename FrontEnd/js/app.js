var editor = ace.edit("editor");
editor.setTheme("ace/theme/terminal");
editor.session.setMode("ace/mode/java");

var editor2 = ace.edit("editor2");
editor2.setTheme("ace/theme/terminal");
editor2.session.setMode("ace/mode/java");

var errores= [];

function getText() {
  var editor = ace.edit("editor");
  var contenido = editor.getSession().getValue();
  var data = { DATA: contenido.toString() };

  fetch('http://localhost:3000/parse', {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(data),
  })
  .then(function(res){return res.json();})
  .then(function(data){ 
    console.log(data);
    treeView(data);
  });
}

function treeView(json)
{
  document.getElementById("treePlace").innerHTML = "";
  var render = renderjson(json.AST);
  this.errores = json.Errores;
  document.getElementById("treePlace").appendChild(render);
}

function openFile(e) {
  var file = e.target.files[0];
  if (!file) {
    return;
  }
  var reader = new FileReader();
  reader.onload = function (e) {
    var contents = e.target.result;
    // Display file content
    displayContents(contents);
  };
  reader.readAsText(file);
}

function displayContents(contents) {
  var editor = ace.edit("editor");
  editor.getSession().setValue("");
  editor.getSession().setValue(contents);
}

document.getElementById('file-input').addEventListener('change', openFile, false);
