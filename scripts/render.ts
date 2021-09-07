#! /usr/env/bin ts-node


const parser = require('@jscad/openscad-openjscad-translator')
const stlSerializer = require('@jscad/stl-serializer')


var fs = require('fs')

var openSCADText = fs.readFileSync("./enclosure/front.scad", "UTF8")
var openJSCADResult = parser.parse(openSCADText)

console.log(openJSCADResult)


const rawData = stlSerializer.serialize({binary: true}, eval(openJSCADResult))

