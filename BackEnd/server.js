/**
 * Le decimos a la aplicación que librerias vamos a utilizar.
*/
var fs = require('fs'); 
var parser = require('./gramatica');
var express = require('express');
var app = express();
var bodyParser = require("body-parser");
var cors = require("cors");

/**
 * Sirve para poder recibir los archivos en formato JSON.
*/
app.use(express.json());
app.use(bodyParser.json());
app.use(cors());

/**
 * Le damos permisos para acceder.
*/
app.use(function(req, res, next) {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Methods", "POST, PUT, GET, OPTIONS");
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
   next();
  });

app.listen(3000, () => console.log('App running on port 3000.'));


app.post('/parse', (req, res) =>
{
    console.log("\n<---------------- INICIO DE ANÁLISIS ------------------->");
    var analyze = req.body.DATA;
    var ast = getAst(analyze.toString());
    var ans = JSON.stringify(ast, null, 2);
    res.send(ans);
    console.log("\n<------------------ FIN DE ANÁLISIS -------------------->");
});

app.get('/', (req, res) => 
{
    console.log("Activo");
    res.send("Sevidor escuchando");
});


function getAst(texto)
{
    var ast;
    try {
        // invocamos a nuestro parser con el contendio del archivo de entradas
        ast = parser.parse(texto);
        // imrimimos en un archivo el contendio del AST en formato JSON
        //fs.writeFileSync('./ast.json', JSON.stringify(ast, null, 2));
        return ast;
    } catch (e) {
        console.error(e);
        return;
    }
}
