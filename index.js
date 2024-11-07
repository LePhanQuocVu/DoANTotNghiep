var express = require('express')
var app = express()

const port = 3000

app.get('/tintuc', function (req, res) {
  res.send('hello world')
})

app.listen(port, () => console.log(`Example app listening at http://localhost:${port}`));