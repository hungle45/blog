---
date: "2026-04-07T15:44:09+07:00"
draft: false
title: "Go Http Timeout"
references:
  - title: The Complete Guide to Golang net/http Timeouts
    url: "https://blog.cloudflare.com/the-complete-guide-to-golang-net-http-timeouts/"
  - title: Exposing Go on the Internet
    url: "https://blog.cloudflare.com/exposing-go-on-the-internet/"
---

### SetDeadline

To implement timeouts in Go, network primitives expose **deadlines** via `net.Conn.Set[Read|Write]Deadline`

> “Deadlines are not timeouts.” They represent an absolute point in time. If an I/O operation does not complete before that moment, it fails with a timeout error.

Because deadlines are absolute, they **do not automatically reset** after each read or write. That means you must explicitly call `SetDeadline` before every I/O operation.

```go
func handle(conn net.Conn) {
    timeout := 5 * time.Second

    for {
        /// Deadline must be an absolute time (Now + Duration)
        conn.SetDeadline(time.Now().Add(timeout))

        buf := make([]byte, 1024)
        n, err := conn.Read(buf)
        
        if err != nil {
            // If err is a timeout, it's because the absolute time was reached
            return 
        }
    
        // Process buf[:n]...
    }
}
```

If you set the deadline only once (outside the loop), the connection will expire after the initial timeout window and all subsequent operations will fail.

---

### Server Timeout

Configuring timeouts on the server side is critical. Without them, slow or disconnected clients can cause **file descriptor leaks**, eventually leading to errors like “too many open files.”

{{< figure src="images/til/go_http_timeout/server-timeout.png" align="center" attr="Go HTTP Server Timeout Lifecycle" width="90%" >}}

Typically, `WriteTimeout` covers the period from the end of request header reading to the completion of the response write.

However, for HTTPS connections, the behavior is slightly different: `SetWriteDeadline` is called immediately after `Accept`, so `WriteTimeout` also includes the header read and the first byte wait.

```go
srv := &http.Server{
    ReadTimeout: 5 * time.Second,   // used to called SetReadDeadline
    WriteTimeout: 10 * time.Second, // used to called SetWriteDeadline
}
```

Note that the package-level functions like `http.ListenAdnServe`, `http.ListenAndServeTLS`, and `http.Serve` come with no timeous, so be mindful when using them.

---

### Client Timeout

Client-side timeouts are generally simpler.

{{< figure src="images/til/go_http_timeout/client-timeout.png" align="center" attr="Go HTTP Client Timeout Lifecycle" width="90%" >}}

The easiest approach is to use `http.Client.Timeout`, which applies to the entire request lifecycle, from Dial to reading response.

```go
c := &http.Client{
    Timeout: 10 * time.Second,
}
```

For more fine-grained control, you can configure lower-level timeouts:

```go
c := &http.Client{
    Timeout: 10 * time.Second,
    Transport: &http.**Transport**{
        DialContext: (&net.Dialer{
            Timeout:   5 * time.Second,
            KeepAlive: 30 * time.Second,
        }).DialContext,
        IdleConnTimeout:       90 * time.Second,
        TLSHandshakeTimeout:   5 * time.Second,
        ExpectContinueTimeout: 1 * time.Second,
    },
}
```

Note that a Client follows redirects by default and `http.Client.Timeout` includes all time spent following redirects while other granular timeous apply per request attempt, not across redirects.
