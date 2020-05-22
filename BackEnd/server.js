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

/*
 * Variables auxiliares
 */

 var clases_a1=[];
 var clases_a2=[];
 
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
    console.log("\n----------------- [Análisis archivo 1] ------------------ ");
    clases_a1 = [];
    var analyze = req.body.DATA;
    var ast = getAst(analyze.toString());
    var ans = JSON.stringify(ast, null, 2);
    clases_a1 = ast['Clases'];
    res.send(ans);
    console.log("\n ------------------------- [Fin]------------------------- ");
});

app.post('/parse2', (req, res) =>
{
    console.log("\n----------------- [Análisis archivo 2] ------------------ ");
    clases_a2 = [];
    var analyze = req.body.DATA;
    var ast = getAst(analyze.toString());
    var ans = JSON.stringify(ast, null, 2);
    clases_a2 = ast['Clases'];
    res.send(ans);
    console.log("\n *------------------------ [Fin]------------------------* ");
});

app.get('/comparar', (req, res) =>
{
    console.log("\n----------------- [Análisis copia] -------------------- ");
    var copias=[];
    for(var i in clases_a1)
    {
        var class1 = clases_a1[i];
        for(var j in clases_a2)
        {
            var class2 = clases_a2[j];
            console.log(class1.nombre + " | " + class2.nombre );
            if(class2.nombre == class1.nombre) 
            {
                console.log("Funciona");
                copias.push(class1);
            }
        }
    }
    var ans = JSON.stringify(copias, null, 2);
    console.log(copias);
    res.send(copias);
    console.log("\n *------------------------ [Fin]------------------------* ");
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
        return ast;
    } catch (e) {
        console.error(e);
        return;
    }
}
