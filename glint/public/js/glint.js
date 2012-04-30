$(document).ready(function() {
    var r = Raphael('history', 900, 240)
    var rHist = r.g.linechart(0, 0, 900, 240, hist.x, hist.y,
        {nostroke: false, axis: "0 0 1 1", symbol: "", smooth: true, shade: true, gutter: 50, width: 1})
        
    var r = Raphael('pie', 640, 300)
    var rPie = r.g.piechart(140, 140, 120, curr.values, {legend: curr.legend})
    rPie.hover(function () {
        this.sector.stop();
        this.sector.scale(1.1, 1.1, this.cx, this.cy);
        if (this.label) {
            this.label[0].stop();
            this.label[0].scale(1.5);
            this.label[1].attr({"font-weight": 800});
        }
    }, function () {
        this.sector.animate({scale: [1, 1, this.cx, this.cy]}, 500, "bounce");
        if (this.label) {
            this.label[0].animate({scale: 1}, 500, "bounce");
            this.label[1].attr({"font-weight": 400});
        }
    });
    
    // D3
    
    margin = 50
    w = 1000
    h = 500
    
    hist.dates = hist.x.map(function(val){return new Date(val*1000)})
    
    var vis = d3.select('#hist2')
                .append('svg:svg')
                .attr('width', w)
                .attr('height', h)
    var g = vis.append('svg:g')
                .attr('transform', 'translate(0,'+h+')')
    
    y = d3.scale.linear().domain([0, d3.max(hist.y)]).range([0 + margin, h - margin]),
    x = d3.scale.linear().domain([0, d3.max(hist.x)]).range([0 + margin, w - margin])
    
    var line = d3.svg.line()
        .x(function(d,i) {return x(i)})
        .y(function(d) {return -1 * y(d)})
    
    g.append('svg:path').attr('d', line(hist.y))
    g.append("svg:line")
        .attr("x1", x(0))
        .attr("y1", -1 * y(0))
        .attr("x2", x(w))
        .attr("y2", -1 * y(0))
    g.append("svg:line")
        .attr("x1", x(0))
        .attr("y1", -1 * y(0))
        .attr("x2", x(0))
        .attr("y2", -1 * y(d3.max(hist.y)))
    g.selectAll(".xLabel")
        .data(x.ticks(5))
        .enter().append("svg:text")
        .attr("class", "xLabel")
        .text(String)
        .attr("x", function(d) { return x(d) })
        .attr("y", 0)
        .attr("text-anchor", "middle")
    g.selectAll(".yLabel")
        .data(y.ticks(4))
        .enter().append("svg:text")
        .attr("class", "yLabel")
        .text(String)
        .attr("x", 0)
        .attr("y", function(d) { return -1 * y(d) })
        .attr("text-anchor", "right")
        .attr("dy", 4)
    g.selectAll(".xTicks")
        .data(x.ticks(5))
        .enter().append("svg:line")
        .attr("class", "xTicks")
        .attr("x1", function(d) { return x(d); })
        .attr("y1", -1 * y(0))
        .attr("x2", function(d) { return x(d); })
        .attr("y2", -1 * y(-0.3))
    g.selectAll(".yTicks")
        .data(y.ticks(4))
        .enter().append("svg:line")
        .attr("class", "yTicks")
        .attr("y1", function(d) { return -1 * y(d); })
        .attr("x1", x(-0.3))
        .attr("y2", function(d) { return -1 * y(d); })
        .attr("x2", x(0))
        
        
    var vis2 = d3.select('#hist3')
                .append('svg:svg')
                .attr('width', w)
                .attr('height', h)
    var g = vis.append('svg:g')
                .attr('transform', 'translate(0,'+h+')')
                
    
})