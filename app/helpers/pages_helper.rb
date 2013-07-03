module PagesHelper

  def bubblemap(map)

    javascript_tag('
    var w = 550,
        h = 450

    var r = 50;

    var fontMax = 18;

    var charge = -30;

    var constraint = 20;

    var axisFont = "12px";
var SVG = d3.select("#viz")
    .append("svg")
    .attr("width", w)
    .attr("height", h)
    .attr("pointer-events", "all")
    .append("svg:g")
    .call(d3.behavior.zoom().on("zoom", redraw))
    .append("svg:g");


SVG.append("svg:rect")
    .attr("width", w)
    .attr("height", h)
    .attr("fill", "white");

function redraw() {
  console.log("here", d3.event.translate, d3.event.scale);
  SVG.attr("transform",
      "translate(" + d3.event.translate + ")"
      + " scale(" + d3.event.scale + ")");
}

z = 1;


d3.json("/maps/' + map.name.to_s + '.json", function(dataset) {


var xScale = [d3.min(dataset, function(d) { return d.buzz; }), d3.max(dataset, function(d) { return d.buzz; })];

var yScale = [0, d3.max(dataset, function(d) { return d.links; })/z];

var x = d3.scale.linear()
                     .domain(xScale)
                     .range([50, w-50]);

var ycolor = d3.scale.linear()
                      .domain(yScale)
                      .range(["rgb(28, 110, 179)", "rgb(205, 232, 255)"])

var y = d3.scale.linear()
                     .domain(yScale)
                     .range([h-50, 50]);


var radius = d3.scale.linear()
                     .domain([0, d3.max(dataset, function(d) { return d.size; })/z])
                     .range([0, r]);


var fontSize =  d3.scale.linear()
                     .domain([0, d3.max(dataset, function(d) { return d.size; })/z])
                     .range([0, fontMax]);

var nodes = [];

dataset.forEach(function(d){
  nodes.push({buzz: d.buzz, links: d.links, size: d.size, name: d.name});
});

 var force = d3.layout.force()
     .charge(function(d){return radius(d.size)* charge;})
     .size([w, h]);


var circle = SVG.selectAll("circle")
    .data(nodes)
    .enter().append("circle")
    .style("fill", function(d){return ycolor(d.links)})
    .attr("height", 40)
    .attr("width", 75)
    .attr("class", function(d){return d.name})
    .attr("cx", function(d){return x(d.buzz)})
    .attr("cy", function(d){return y(d.links)})
    .attr("r", function(d){return radius(d.size);});


var text = SVG.selectAll("text")
    .data(nodes)
    .enter()
    .append("svg:a")
    .attr("xlink:href", function(d){return "/tags/list_posts?name=" + d.name + "&source=' + map.source + '"})
    .attr("data-remote", "true")
    .append("text")
    .attr("text-anchor", "middle")
    .attr("font-size", function(d){return fontSize(d.size)})
    .attr("class", function(d){return d.name})
    .attr("x", function(d){return x(d.buzz)})
    .attr("y", function(d){return y(d.links)})
    .text(function(d){return d.name});

   force
       .nodes(nodes)
       .start();

SVG.append("g")
    .attr("id", "xAxis")
    .append("line")
      .attr("x1", 0)
      .attr("y1", h-20)
      .attr("x2", w)
      .attr("y2", h-20)
      .attr("stroke", "black")

SVG.select("#xAxis")
    .append("text")
      .attr("x", 10)
      .attr("y", h-25)
      .attr("fill", "steelblue")
      .attr("font-size", axisFont)
      .attr("font-weight", "bold")
      .text("Trending Down");

SVG.select("#xAxis")
    .append("text")
      .attr("text-anchor", "end")
      .attr("x", w-10)
      .attr("y", h-25)
      .attr("fill", "steelblue")
      .attr("font-size", axisFont)
      .attr("font-weight", "bold")
      .text("Trending Up");


SVG.append("g")
    .attr("id", "yAxis")
    .append("line")
      .attr("x1", 0)
      .attr("y1", h-20)
      .attr("x2", 0)
      .attr("y2", 20)
      .attr("stroke", "black")


SVG.select("#yAxis")
    .append("text")
      .attr("text-anchor", "end")
      .attr("x", h-50)
      .attr("y", -10)
      .attr("fill", "steelblue")
      .attr("font-size", axisFont)
      .attr("font-weight", "bold")
      .attr("transform", "rotate(90)")
      .text("Peripheral");

SVG.select("#yAxis")
    .append("text")
      .attr("text-anchor", "end")
      .attr("x", 70)
      .attr("y", -10)
      .attr("fill", "steelblue")
      .attr("font-size", axisFont)
      .attr("font-weight", "bold")
      .attr("transform", "rotate(90)")
      .text("Central");


   force.on("tick", function(nodes) {

     text.attr("x", function(d) { return x(d.buzz ) + d.x/constraint; })
         .attr("y", function(d) { return y(d.links) + d.y/constraint; });

     circle.attr("cx", function(d) { return x(d.buzz) + d.x/constraint; })
         .attr("cy", function(d) { return y(d.links) + d.y/constraint; });

    });
});



')
  end

  #
  #var force = d3.layout.force()
  #.nodes(d3.values(nodes))
  #.charge(-30)
  #.on("tick", tick)
  #.size([w, h])
  #.start();
  end
