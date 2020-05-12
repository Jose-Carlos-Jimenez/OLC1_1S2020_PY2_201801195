var fs = require('fs'); 
var parser = require('./gramatica');
var express = require('express');
var app = express();

app.get('/parse', (req, res ) =>
{
    var analyze = req.body;
    console.log(analyze);
    res.send('Archivo de entrada recibido.'); 
});


app.listen(3000, () => console.log('App running on port 3000.'));

var ast;
try {
    // leemos nuestro archivo de entrada
    var entrada = fs.readFileSync('./entrada.txt');
    // invocamos a nuestro parser con el contendio del archivo de entradas
    ast = parser.parse(entrada.toString());

    // imrimimos en un archivo el contendio del AST en formato JSON
    fs.writeFileSync('./ast.json', JSON.stringify(ast, null, 2));
} catch (e) {
    console.error(e);
    return;
}