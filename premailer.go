package main

import (
	"flag"
	"github.com/go-martini/martini"
	"github.com/martini-contrib/render"
	"github.com/vanng822/go-premailer/premailer"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
)

func main() {
	var (
		host string
		port int
	)

	flag.StringVar(&host, "h", "127.0.0.1", "Host to listen on")
	flag.IntVar(&port, "p", 9998, "Port number to listen on")
	flag.Parse()

	sigc := make(chan os.Signal, 1)
	signal.Notify(sigc, os.Kill, os.Interrupt, syscall.SIGTERM, syscall.SIGUSR2)
	app := martini.Classic()
	app.Use(render.Renderer(render.Options{
		Directory:  "templates",                 // Specify what path to load the templates from.
		Extensions: []string{".html"},           // Specify extensions to load for templates.
		Delims:     render.Delims{"{[{", "}]}"}, // Sets delimiters to the specified strings.
		Charset:    "UTF-8",                     // Sets encoding for json and html content-types. Default is "UTF-8".
		IndentJSON: true,                        // Output human readable JSON
	}))

	app.Get("/", func(r render.Render) {
		r.HTML(http.StatusOK, "index", nil)
	})
	app.Post("/convert", func(r render.Render, req *http.Request) {
		req.ParseForm()
		html := req.Form.Get("html")
		var result string
		if html != "" {
			pre := premailer.NewPremailerFromString(html)
			result, _ = pre.Transform()
		} else {
			result = ""
		}
		r.JSON(http.StatusOK, map[string]string{"result": result})
	})
	log.Printf("listening to address %s:%d", host, port)
	go http.ListenAndServe(fmt.Sprintf("%s:%d", host, port), app)
	sig := <-sigc
	log.Printf("Got signal: %s", sig)

}
