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