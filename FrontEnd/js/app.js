var editor = ace.edit("editor");
editor.setTheme("ace/theme/terminal");
editor.session.setMode("ace/mode/java");

var toggler = document.getElementsByClassName("caret");
var i;

for (i = 0; i < toggler.length; i++) {
  toggler[i].addEventListener("click", function() {
    this.parentElement.querySelector(".nested").classList.toggle("active");
    this.classList.toggle("caret-down");
  });
}

function getText()
{
  var editor = ace.edit("editor");
  var contenido = editor.getSession().getValue();
  var data = {DATA : contenido.toString()};

  fetch('http://localhost:3000/parse', {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(data),
    
  })
    .then((response) => 
    {
      console.log("Recibido.");
    })
    .catch((error) => console.error("Error: ", error));
}

function openFile(e)
{
  var file = e.target.files[0];
  if (!file) {
    return;
  }
  var reader = new FileReader();
  reader.onload = function(e) {
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

document.getElementById('file-input').addEventListener('change', openFile, false);
