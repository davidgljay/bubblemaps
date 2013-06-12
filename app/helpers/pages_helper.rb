module PagesHelper

  def bubblemap

    javascript_tag('
    var w = 850,
        h = 700

    var r = 100;

var SVG = d3.select("#viz")
    .append("svg")
    .attr("width", w)
    .attr("height", h)
    .attr("pointer-events", "all")
    .append("svg:g")
    .call(d3.behavior.zoom().on("zoom", redraw))
    .append("svg:g");
;



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


d3.json("/maps/3", function(dataset) {

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
                     .range([0, 35]);

SVG.selectAll("circle")
    .data(dataset)
    .enter().append("circle")
    .style("fill", function(d){return ycolor(d.links)})
    .attr("height", 40)
    .attr("width", 75)
    .attr("class", function(d){return d.name})
    .attr("cx", function(d){return x(d.buzz)})
    .attr("cy", function(d){return y(d.links)})
    .attr("r", function(d){return radius(d.size);});

SVG.selectAll("text")
    .data(dataset)
    .enter().append("text")
    .attr("text-anchor", "middle")
    .attr("font-size", function(d){return fontSize(d.size)})
    .attr("class", function(d){return d.name})
    .attr("dx", function(d){return x(d.buzz)})
    .attr("dy", function(d){return y(d.links)})
    .text(function(d){return d.name});

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
      .attr("dx", 10)
      .attr("dy", h-25)
      .attr("fill", "steelblue")
      .attr("font-size", "14px")
      .attr("font-weight", "bold")
      .text("Trending Down");

SVG.select("#xAxis")
    .append("text")
      .attr("text-anchor", "end")
      .attr("dx", w-10)
      .attr("dy", h-25)
      .attr("fill", "steelblue")
      .attr("font-size", "14px")
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
      .attr("dx", 10)
      .attr("dy", h-25)
      .attr("fill", "steelblue")
      .attr("font-size", "14px")
      .attr("font-weight", "bold")
      .text("Trending Down");

SVG.select("#yAxis")
    .append("text")
      .attr("text-anchor", "end")
      .attr("dx", h-50)
      .attr("dy", -10)
      .attr("fill", "steelblue")
      .attr("font-size", "14px")
      .attr("font-weight", "bold")
      .attr("transform", "rotate(90)")
      .text("Peripheral");

SVG.select("#yAxis")
    .append("text")
      .attr("text-anchor", "end")
      .attr("dx", 70)
      .attr("dy", -10)
      .attr("fill", "steelblue")
      .attr("font-size", "14px")
      .attr("font-weight", "bold")
      .attr("transform", "rotate(90)")
      .text("Central");
});



')
  end

  def test

    javascript_tag('

var maxRadius = 100;

var partition = d3.layout.partition()
    .value(function(d) { return d.size; });


d3.json("/maps/1", function(root) {

	var radius = d3.scale.linear()
				.domain([0, 100])
				.range([0,maxRadius]);

var sampleSVG = d3.select("#viz")
    .append("svg")
    .attr("width", 900)
    .attr("height", 500);

sampleSVG.selectAll("circle")
    .data(partition.nodes(root))
    .enter().append("circle")
    .style("stroke", "gray")
    .style("fill", "white")
    .attr("height", 40)
    .attr("width", 75)
    .attr("cx", 200)
    .attr("cy", 200)
    .attr("r",function(d){return d.dx})
});
')

  end


  def baby_sunburst(data)
    javascript_tag('

var width = 960,
    height = 700,
    radius = Math.min(width, height) / 2;

var x = d3.scale.linear()
    .range([0, 2 * Math.PI]);

var y = d3.scale.sqrt()
    .range([0, radius]);

var color = d3.scale.category20c();

var svg = d3.select("body").append("svg")
    .attr("width", width)
    .attr("height", height)
  .append("g")
    .attr("transform", "translate(" + width / 2 + "," + (height / 2 + 10) + ")");

var partition = d3.layout.partition()
    .value(function(d) { return d.size; });

var arc = d3.svg.arc()
    .startAngle(function(d) { return Math.max(0, Math.min(2 * Math.PI, x(d.x))); })
    .endAngle(function(d) { return Math.max(0, Math.min(2 * Math.PI, x(d.x + d.dx))); })
    .innerRadius(function(d) { return Math.max(0, y(d.y)); })
    .outerRadius(function(d) { return Math.max(0, y(d.y + d.dy)); })

var color =
      (function (d){
      c =  d*250/d3.max(root)
      "rgb(" + c + ",200,0)"
      })

d3.json("/maps/' + data.to_s + '", function(error, root) {
  if (error) return console.warn(error);

  var path = svg.selectAll("path")
      .data(partition.nodes(root))
    .enter().append("path")
      .attr("d", arc)


});

')


  end

  def sunburst(data = nil)
    javascript_tag('

var width = 840,
    height = width,
    radius = width / 2,
    x = d3.scale.linear().range([0, 2 * Math.PI]),
    y = d3.scale.pow().exponent(1.3).domain([0, 1]).range([0, radius]),
    padding = 5,
    duration = 1000;

var div = d3.select("#vis");

div.select("img").remove();

var vis = div.append("svg")
    .attr("width", width + padding * 2)
    .attr("height", height + padding * 2)
  .append("g")
    .attr("transform", "translate(" + [radius + padding, radius + padding] + ")");

div.append("p")
    .attr("id", "intro")
    .text("Click to zoom!");

var partition = d3.layout.partition()
    .sort(null)
    .value(function(d) { return 5.8 - d.depth; });

var arc = d3.svg.arc()
    .startAngle(function(d) { return Math.max(0, Math.min(2 * Math.PI, x(d.x))); })
    .endAngle(function(d) { return Math.max(0, Math.min(2 * Math.PI, x(d.x + d.dx))); })
    .innerRadius(function(d) { return Math.max(0, d.y ? y(d.y) : d.y); })
    .outerRadius(function(d) { return Math.max(0, y(d.y + d.dy)); });

d3.json("http://www.jasondavies.com/coffee-wheel/wheel.json", function(json) {
  var nodes = partition.nodes({children: json});

  var path = vis.selectAll("path").data(nodes);
  path.enter().append("path")
      .attr("id", function(d, i) { return "path-" + i; })
      .attr("d", arc)
      .attr("fill-rule", "evenodd")
      .style("fill", colour)
      .on("click", click);

  var text = vis.selectAll("text").data(nodes);
  var textEnter = text.enter().append("text")
      .style("fill-opacity", 1)
      .style("fill", function(d) {
        return brightness(d3.rgb(colour(d))) < 125 ? "#eee" : "#000";
      })
      .attr("text-anchor", function(d) {
        return x(d.x + d.dx / 2) > Math.PI ? "end" : "start";
      })
      .attr("dy", ".2em")
      .attr("transform", function(d) {
        var multiline = (d.name || "").split(" ").length > 1,
            angle = x(d.x + d.dx / 2) * 180 / Math.PI - 90,
            rotate = angle + (multiline ? -.5 : 0);
        return "rotate(" + rotate + ")translate(" + (y(d.y) + padding) + ")rotate(" + (angle > 90 ? -180 : 0) + ")";
      })
      .on("click", click);
  textEnter.append("tspan")
      .attr("x", 0)
      .text(function(d) { return d.depth ? d.name.split(" ")[0] : ""; });
  textEnter.append("tspan")
      .attr("x", 0)
      .attr("dy", "1em")
      .text(function(d) { return d.depth ? d.name.split(" ")[1] || "" : ""; });

  function click(d) {
    path.transition()
      .duration(duration)
      .attrTween("d", arcTween(d));

    // Somewhat of a hack as we rely on arcTween updating the scales.
    text.style("visibility", function(e) {
          return isParentOf(d, e) ? null : d3.select(this).style("visibility");
        })
      .transition()
        .duration(duration)
        .attrTween("text-anchor", function(d) {
          return function() {
            return x(d.x + d.dx / 2) > Math.PI ? "end" : "start";
          };
        })
        .attrTween("transform", function(d) {
          var multiline = (d.name || "").split(" ").length > 1;
          return function() {
            var angle = x(d.x + d.dx / 2) * 180 / Math.PI - 90,
                rotate = angle + (multiline ? -.5 : 0);
            return "rotate(" + rotate + ")translate(" + (y(d.y) + padding) + ")rotate(" + (angle > 90 ? -180 : 0) + ")";
          };
        })
        .style("fill-opacity", function(e) { return isParentOf(d, e) ? 1 : 1e-6; })
        .each("end", function(e) {
          d3.select(this).style("visibility", isParentOf(d, e) ? null : "hidden");
        });
  }
});

function isParentOf(p, c) {
  if (p === c) return true;
  if (p.children) {
    return p.children.some(function(d) {
      return isParentOf(d, c);
    });
  }
  return false;
}

function colour(d) {
  if (d.children) {
    // There is a maximum of two children!
    var colours = d.children.map(colour),
        a = d3.hsl(colours[0]),
        b = d3.hsl(colours[1]);
    // L*a*b* might be better here...
    return d3.hsl((a.h + b.h) / 2, a.s * 1.2, a.l / 1.2);
  }
  return d.colour || "#fff";
}

// Interpolate the scales!
function arcTween(d) {
  var my = maxY(d),
      xd = d3.interpolate(x.domain(), [d.x, d.x + d.dx]),
      yd = d3.interpolate(y.domain(), [d.y, my]),
      yr = d3.interpolate(y.range(), [d.y ? 20 : 0, radius]);
  return function(d) {
    return function(t) { x.domain(xd(t)); y.domain(yd(t)).range(yr(t)); return arc(d); };
  };
}

function maxY(d) {
  return d.children ? Math.max.apply(Math, d.children.map(maxY)) : d.y + d.dy;
}

// http://www.w3.org/WAI/ER/WD-AERT/#color-contrast
function brightness(rgb) {
  return rgb.r * .299 + rgb.g * .587 + rgb.b * .114;
}

')
  end
end

