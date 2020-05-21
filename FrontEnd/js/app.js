var editor = ace.edit("editor");
editor.setTheme("ace/theme/terminal");
editor.session.setMode("ace/mode/java");

var editor2 = ace.edit("editor2");
editor2.setTheme("ace/theme/terminal");
editor2.session.setMode("ace/mode/java");


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
    treeView(data);
  });
  
  // Visualización del árbol.
  
}

function treeView(json)
{
  document.getElementById("treePlace").innerHTML = "";
  document.getElementById("treePlace").appendChild(renderjson(json));
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
    console.log(contents);
    displayContents(contents);
  };
  reader.readAsText(file);
}

function displayContents(contents) {
  var editor = ace.edit("editor");
  editor.getSession().setValue(contents);
}

function getJson() {
  var json = {
    "root": {
      "imports": [
        {
          "clase": "hola"
        },
        {
          "clase": "das"
        },
        {
          "clase": "nel"
        }
      ],
      "clases": [
        {
          "nombre": "Principal",
          "cuerpo": [
            {
              "operacion": "declaracion",
              "tipo": "int",
              "declaradas": [
                "a",
                "b",
                "c"
              ]
            },
            {
              "operacion": "declaracion",
              "tipo": "String",
              "declaradas": [
                "r"
              ]
            },
            {
              "operacion": "declaracion",
              "tipo": "char",
              "declaradas": [
                "c"
              ]
            },
            "void"
          ]
        },
        {
          "nombre": "Secundaria",
          "cuerpo": [
            null
          ]
        },
        {
          "nombre": "Tercera",
          "cuerpo": [
            "Tercera"
          ]
        }
      ]
    }
  };
  return json;
}

document.getElementById('file-input').addEventListener('change', openFile, false);
