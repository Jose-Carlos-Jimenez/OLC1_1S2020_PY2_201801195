package main

import (
	"fmt"
	"html/template"
	"net/http"
)

func index(w http.ResponseWriter, r *http.Request) {
	t := template.Must(template.ParseFiles("index.html"))
	t.Execute(w, nil)
}

func main() {
	http.Handle("/js/", http.StripPrefix("/js/", http.FileServer(http.Dir("js/"))))
	http.HandleFunc("/", index)
	http.HandleFunc("/otherpage", index)
	fmt.Printf("Servidor iniciado")
	http.ListenAndServe(":9000", nil)
}
