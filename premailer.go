package main

import (
	"flag"
	"fmt"

	"github.com/unrolled/render"
	"github.com/vanng822/go-premailer/premailer"
	"github.com/vanng822/r2router"

	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"

	"github.com/vanng822/recovery"
)

func main() {
	var (
		host string
		port int
	)

	flag.StringVar(&host, "h", "0.0.0.0", "Host to listen on")
	flag.IntVar(&port, "p", 9998, "Port number to listen on")
	flag.Parse()

	sigc := make(chan os.Signal, 1)
	signal.Notify(sigc, os.Kill, os.Interrupt, syscall.SIGTERM, syscall.SIGUSR2)
	app := r2router.NewSeeforRouter()
	rec := recovery.NewRecovery()
	app.Before(rec.Handler)

	r := render.New(render.Options{
		Directory:       "templates",
		Layout:          "",
		Extensions:      []string{".html"},
		Charset:         "UTF-8",
		IndentJSON:      true,
		IndentXML:       false,
		HTMLContentType: "text/html",
		IsDevelopment:   false,
	})

	app.Get("/", func(w http.ResponseWriter, req *http.Request, _ r2router.Params) {
		r.HTML(w, http.StatusOK, "index", nil)
	})
	app.Post("/convert", func(w http.ResponseWriter, req *http.Request, _ r2router.Params) {
		req.ParseForm()
		html := req.Form.Get("html")
		cssToAttributes := req.Form.Get("cssToAttributes")
		removeClasses := req.Form.Get("removeClasses")
		var result string
		if html != "" {
			options := premailer.NewOptions()
			if removeClasses == "true" {
				options.RemoveClasses = true
			}
			if cssToAttributes == "false" {
				options.CssToAttributes = false
			}
			pre, err := premailer.NewPremailerFromString(html, options)
			if err == nil {
				result, _ = pre.Transform()
			}
		} else {
			result = ""
		}
		r.JSON(w, http.StatusOK, map[string]string{"result": result})
	})

	timer := app.UseTimer(nil)

	app.Get("/timers", func(w http.ResponseWriter, req *http.Request, _ r2router.Params) {
		timer.ServeHTTP(w, req)
	})

	log.Printf("listening to address %s:%d", host, port)
	go http.ListenAndServe(fmt.Sprintf("%s:%d", host, port), app)
	sig := <-sigc
	log.Printf("Got signal: %s", sig)

}
